//
//  DetailViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit

final class DetailViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        case shareButtonTapped
        case edit
        case delete
    }
    
    enum Mutation {
        case loadData
        case shareData([Data]?)
        case editExpense(Receipt?)
        case deleteExpense(Void?)
        case updateExpense(Receipt)
        case onError(Error?)
    }
    
    struct State {
        var title: String
        var expense: Receipt
        var priceText: String
        var shareExpense: [Data]?
        var editExpense: Receipt?
        var deleteExpense: Void?
        var dataError: Error?
    }
    
    let initialState: State
    
    // Properties
    
    private let expenseRepository: ExpenseRepository
    private let currencyRepository: CurrencyRepository
    
    // Initializer
    
    init(
        title: String,
        expenseRepository: ExpenseRepository,
        currencyRepository: CurrencyRepository,
        item: Receipt
    ) {
        self.expenseRepository = expenseRepository
        self.currencyRepository = currencyRepository
       
        initialState = State(title: title, expense: item, priceText: "")
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
            
        case .shareButtonTapped:
            return Observable.concat([
                Observable.just(Mutation.shareData(currentState.expense.receiptData)),
                Observable.just(Mutation.shareData(nil))
            ])
                
        case .edit:
            return Observable.concat([
                Observable.just(Mutation.editExpense(currentState.expense)),
                Observable.just(Mutation.editExpense(nil))
            ])
            
        case .delete:
            let expense = currentState.expense
            return expenseRepository.delete(expense: expense)
                .flatMap { _ in
                    return Observable.just(Mutation.deleteExpense(Void()))
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.onError(error)),
                        Observable.just(Mutation.onError(nil))
                    ])
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            newState = changeState(currentState: state, data: currentState.expense)
        
        case .shareData(let datas):
            newState.shareExpense = datas
            
        case .editExpense(let expense):
            newState.editExpense = expense
            
        case .deleteExpense(let void):
            newState.deleteExpense = void
            
        case .updateExpense(let updatedExpense):
            newState = changeState(currentState: state, data: updatedExpense)
            
        case .onError(let error):
            newState.dataError = error
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let updateEvent = expenseRepository.saveEvent
            .flatMap { Observable.just(Mutation.updateExpense($0)) }
        
        return Observable.merge(mutation, updateEvent)
    }
}

extension DetailViewReactor {
    private func changeState(currentState: State, data: Receipt) -> State {
        let currencyIndex = currencyRepository.fetch()
        let currency = Currency(rawValue: currencyIndex) ?? .KRW
        
        var newState = currentState
        newState.expense = data
        newState.priceText = convertPriceFormat(data.priceText, currency: currency)
        return newState
    }
    
    private func convertPriceFormat(_ price: String, currency: Currency) -> String {
        return NumberFormatter.numberDecimal(from: price) + currency.description
    }
}
