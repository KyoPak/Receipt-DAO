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
//        case imageTapped
//        case imageSwipe
    }
    
    enum Mutation {
        case loadData
        case shareData
//        case imageSwipe
    }
    
    struct State {
        var title: String
        var expense: Receipt
        var dateText: String
        var priceText: String
        var expenseImageData: [Data]
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
        
        initialState = State(
            title: title,
            expense: item,
            dateText: dateText,
            priceText: priceText,
            expenseImageData: []
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
            
        case .shareButtonTapped:
            return Observable.just(Mutation.shareData)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            break
        case .shareData:
            newState.expenseImageData = newState.expense.receiptData
        }
        
        return newState
    }
}
