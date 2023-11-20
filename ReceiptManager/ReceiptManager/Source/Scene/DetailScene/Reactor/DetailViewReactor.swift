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
    }
    
    enum Mutation {
        case loadData
        case shareData([Data])
        case imageSwipe(String)
    }
    
    struct State {
        var title: String
        var expense: Receipt
        var dateText: String
        var priceText: String
        var expenseImageData: [Data]
        var imagePageText: String
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
            expenseImageData: [],
            imagePageText: imagePageText
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
            
        case .shareButtonTapped:
            return Observable.just(Mutation.shareData(currentState.expense.receiptData))
            
        case .imageSwipe(let bound):
            let currentPage = Int(bound.midX / bound.width) + 1
            let totalPage = currentState.expense.receiptData.count
            
            return Observable.just(Mutation.imageSwipe(countPageText(total: totalPage, current: currentPage)))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.expenseImageData.removeAll()
        
        switch mutation {
        case .loadData:
            break
        
        case .shareData(let datas):
            newState.expenseImageData = datas
        
        case .imageSwipe(let text):
            newState.imagePageText = text
        }
        
        return newState
    }
}

extension DetailViewReactor {
    private func countPageText(total: Int, current: Int = 1) -> String {
        return total == .zero ? ConstantText.noPicture.localize() : "\(current)/\(total)"
    }
}
