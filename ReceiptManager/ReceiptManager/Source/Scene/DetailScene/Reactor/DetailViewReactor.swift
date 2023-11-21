//
//  DetailViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit
import RxSwift
import RxCocoa

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
    }
    
    struct State {
        var title: String
        var expense: Receipt
        var dateText: String
        var priceText: String
        var imagePageText: String
        var shareExpense: [Data]?
        var editExpense: Receipt?
        var deleteExpense: Void?
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(title: String, storage: CoreDataStorage, item: Receipt) {
        self.storage = storage
        
        let userCurrency = UserDefaults.standard.integer(forKey: ConstantText.currencyKey)
        let currency = Currency(rawValue: userCurrency)?.description ?? Currency.KRW.description
        let dateText = DateFormatter.string(from: item.receiptDate, ConstantText.dateFormatDay.localize())
        let priceText = NumberFormatter.numberDecimal(from: item.priceText) + currency
        let imagePageText = item.receiptData.count == .zero ?
            ConstantText.noPicture.localize() : "1/\(item.receiptData.count)"
        
        initialState = State(
            title: title,
            expense: item,
            dateText: dateText,
            priceText: priceText,
            imagePageText: imagePageText,
            shareExpense: nil,
            editExpense: nil,
            deleteExpense: nil
        )
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
            break
        
        case .shareData(let datas):
            newState.shareExpense = datas
        
        case .imageSwipe(let text):
            newState.imagePageText = text
            
        case .editExpense(let expense):
            newState.editExpense = expense
            
        case .deleteExpense(let void):
            newState.deleteExpense = void
        }
        
        return newState
    }
}

extension DetailViewReactor {
    private func countPageText(total: Int, current: Int = 1) -> String {
        return total == .zero ? ConstantText.noPicture.localize() : "\(current)/\(total)"
    }
}
