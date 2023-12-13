//
//  SearchViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit

final class SearchViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case searchExpense(String)
    }
    
    enum Mutation {
        case updateSearchResult(String, [ReceiptSectionModel])
    }
    
    struct State {
        var title: String
        var searchText: String
        var searchResult: [ReceiptSectionModel]
    }
    
    let initialState: State
    
    // Properties
    
    private let storageService: StorageService
    let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(storageService: StorageService, userDefaultService: UserDefaultService) {
        self.storageService = storageService
        userDefaultEvent = userDefaultService.event
        initialState = State(title: ConstantText.searchBar.localize(), searchText: "", searchResult: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchExpense(let text):
            return search(text)
                .map { Mutation.updateSearchResult(text, $0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateSearchResult(let text, let searchResult):
            newState.searchText = text
            newState.searchResult = searchResult
        }
        
        return newState
    }
}

extension SearchViewReactor {
    private func search(_ text: String) -> Observable<[ReceiptSectionModel]> {
        return loadData().map { models in
            self.filterData(for: models, by: text)
        }
    }
    
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        let dayFormat = ConstantText.dateFormatMonth.localize()
        
        return storageService.fetch()
            .map { result in
                let dictionary = Dictionary(
                    grouping: result,
                    by: { DateFormatter.string(from: $0.receiptDate, dayFormat) }
                )
                
                let section = dictionary.sorted { return $0.key > $1.key }
                    .map { (key, value) in
                        return ReceiptSectionModel(model: key, items: value)
                    }
                
                return section
            }
    }
    
    private func filterData(for data: [ReceiptSectionModel], by text: String) -> [ReceiptSectionModel] {
        return data.map { model in
            let filteredItems = model.items.filter {
                return $0.store.contains(text) || $0.product.contains(text) ||
                $0.priceText.contains(text) || $0.memo.contains(text)
            }
            return ReceiptSectionModel(model: model.model, items: filteredItems)
        }
        .filter { !$0.items.isEmpty }
    }
}
