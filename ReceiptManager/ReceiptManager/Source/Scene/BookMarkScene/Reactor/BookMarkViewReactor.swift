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
        case cellUnBookMark(IndexPath)
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
            
        case .cellUnBookMark(let indexPath):
            var expense = currentState.expenseByBookMark[indexPath.section].items[indexPath.row]
            expense.isFavorite.toggle()
            storage.upsert(receipt: expense)
            
            return loadData().map { sectionModels in
                return Mutation.loadData(sectionModels)
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let models):
            newState.expenseByBookMark = filterData(for: models)
        }
        
        return newState
    }
}

extension BookMarkViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        let dayFormat = ConstantText.dateFormatMonth.localize()
        
        return storage.fetch()
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
    
    private func filterData(for data: [ReceiptSectionModel]) -> [ReceiptSectionModel] {
        return data.map { model in
            let filteredItems = model.items.filter { $0.isFavorite }
            return ReceiptSectionModel(model: model.model, items: filteredItems)
        }
        .filter { !$0.items.isEmpty }
    }
}
