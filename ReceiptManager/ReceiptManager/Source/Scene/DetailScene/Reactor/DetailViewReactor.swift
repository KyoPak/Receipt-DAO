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
        case imageSwipe(CGRect)
        case edit
        case delete
    }
    
    enum Mutation {
        case loadData
        case shareData([Data]?)
        case imageSwipe(String)
        case editExpense(Receipt?)
        case deleteExpense(Void?)
        case updateExpense(Receipt)
    }
    
    struct State {
        var title: String
        var expense: Receipt
        var priceText: String
        var imagePageText: String
        var shareExpense: [Data]?
        var editExpense: Receipt?
        var deleteExpense: Void?
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let userDefaultService: UserDefaultService
    
    // Initializer
    
    init(title: String, storage: CoreDataStorage, userDefaultService: UserDefaultService, item: Receipt) {
        self.storage = storage
        self.userDefaultService = userDefaultService
       
        initialState = State(title: title, expense: item, priceText: "", imagePageText: "")
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
            
        case .imageSwipe(let bound):
            let currentPage = Int(bound.midX / bound.width) + 1
            let totalPage = currentState.expense.receiptData.count
            
            return Observable.just(Mutation.imageSwipe(countPageText(total: totalPage, current: currentPage)))
            
        case .edit:
            return Observable.concat([
                Observable.just(Mutation.editExpense(currentState.expense)),
                Observable.just(Mutation.editExpense(nil))
            ])
            
        case .delete:
            let expense = currentState.expense
            storage.delete(receipt: expense)
            
            return Observable.just(Mutation.deleteExpense(Void()))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            newState = changeState(currentState: state, data: currentState.expense)
        
        case .shareData(let datas):
            newState.shareExpense = datas
        
        case .imageSwipe(let text):
            newState.imagePageText = text
            
        case .editExpense(let expense):
            newState.editExpense = expense
            
        case .deleteExpense(let void):
            newState.deleteExpense = void
            
        case .updateExpense(let updatedExpense):
            newState = changeState(currentState: state, data: updatedExpense)
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let updateEvent = storage.updateEvent
            .flatMap { Observable.just(Mutation.updateExpense($0)) }
        
        return Observable.merge(mutation, updateEvent)
    }
}

extension DetailViewReactor {
    private func changeState(currentState: State, data: Receipt) -> State {
        let currencyIndex = userDefaultService.fetchCurrencyIndex()
        let currency = Currency(rawValue: currencyIndex) ?? .KRW
        
        var newState = currentState
        newState.expense = data
        newState.priceText = convertPriceFormat(data.priceText, currency: currency)
        newState.imagePageText = countPageText(total: data.receiptData.count)
        return newState
    }
    
    private func convertPriceFormat(_ price: String, currency: Currency) -> String {
        return NumberFormatter.numberDecimal(from: price) + currency.description
    }
    
    private func countPageText(total: Int, current: Int = 1) -> String {
        return total == .zero ? ConstantText.noPicture.localize() : "\(current)/\(total)"
    }
}
