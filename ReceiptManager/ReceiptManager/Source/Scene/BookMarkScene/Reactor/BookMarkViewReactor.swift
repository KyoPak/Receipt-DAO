//
//  BookMarkViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit

final class BookMarkViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        
    }
    
    enum Mutation {
        case loadData([ReceiptSectionModel])
    }
    
    struct State {
        var expenseByBookMark: [ReceiptSectionModel]
    }
    
    let initialState = State(expenseByBookMark: [])
    
    // Properties
    
    private let storage: CoreDataStorage
    let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(storage: CoreDataStorage, userDefaultService: UserDefaultService) {
        self.storage = storage
        userDefaultEvent = userDefaultService.event
    }

    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return loadData().map { sectionModels in
                return Mutation.loadData(sectionModels)
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let models):
            newState.expenseByBookMark = models
        }
        
        return newState
    }
}

extension BookMarkViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .month)
    }
    
    private func filterData(by date: Date, for data: [ReceiptSectionModel]) -> [ReceiptSectionModel] {
        
        return data.map { model in
            let filteredItems = model.items.filter { $0.isFavorite }
            return ReceiptSectionModel(model: model.model, items: filteredItems)
        }
        .filter { !$0.items.isEmpty }
    }
}
