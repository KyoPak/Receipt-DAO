//
//  SearchViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SearchViewReactor: Reactor {
    enum Action {
        case searchExpense(String)       // 검색
//        case expenseCellSelect(IndexPath)
//        case expenseCellBookmark(IndexPath)
    }
    
    enum Mutation {
        case updateSearchResult([ReceiptSectionModel])
        
    }
    
    struct State {
        var title: String
        var searchText: String
        var searchResult: [ReceiptSectionModel]
    }
    
    let initialState = State(title: ConstantText.searchBar.localize(), searchText: "", searchResult: [])
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchExpense(let text):
            return search(text)
                .map { Mutation.updateSearchResult($0) }
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .updateSearchResult(searchResult):
            newState.searchResult = searchResult
        }
        
        return newState
    }
    
    private func search(_ text: String) -> Observable<[ReceiptSectionModel]> {
        return Observable.combineLatest(storage.fetch(type: .month), Observable<String>.just(text))
            .map { receiptSectionModels, text in
                return receiptSectionModels.map { model in
                    let searchItems = model.items.filter { receipt in
                        guard text != "" else { return false }
                        return receipt.store.contains(text) ||
                        receipt.priceText.contains(text) ||
                        receipt.memo.contains(text)
                    }
                    return ReceiptSectionModel(model: model.model, items: searchItems)
                }
                .filter { $0.items.count != .zero }
            }
    }
}
