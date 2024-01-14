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
        case onError(Error?)
    }
    
    struct State {
        var expenseByBookMark: [ReceiptSectionModel]
        var dataError: Error?
    }
    
    let initialState = State(expenseByBookMark: [])
    
    // Properties
    
    private let expenseRepository: ExpenseRepository
    let currencyEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(expenseRepository: ExpenseRepository, currencyRepository: CurrencyRepository) {
        self.expenseRepository = expenseRepository
        currencyEvent = currencyRepository.saveEvent
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
            return expenseRepository.save(expense: expense)
                .withUnretained(self)
                .flatMap { (owner, _) in
                    owner.loadData().map { Mutation.loadData($0) }
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
        case .loadData(let models):
            newState.expenseByBookMark = filterData(for: models)
            
        case .onError(let error):
            newState.dataError = error
        }
        
        return newState
    }
}

extension BookMarkViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        let dayFormat = ConstantText.dateFormatMonth.localize()
        
        return expenseRepository.fetch()
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
