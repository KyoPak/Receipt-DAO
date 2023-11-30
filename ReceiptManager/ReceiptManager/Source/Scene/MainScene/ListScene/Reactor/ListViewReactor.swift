//
//  ListViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit

final class ListViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case cellBookMark(IndexPath)
        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case updateExpenseList([ReceiptSectionModel])
    }
    
    struct State {
        var expenseByMonth: [ReceiptSectionModel]
    }
    
    let initialState = State(expenseByMonth: [])
    
    // Properties
    
    private let storage: CoreDataStorage
    let userDefaultEvent: BehaviorSubject<Int>
    let dateManageEvent: BehaviorSubject<Date>
    
    // Initializer
    
    init(
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.storage = storage
        userDefaultEvent = userDefaultService.event
        dateManageEvent = dateManageService.currentDateEvent
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            expense.isFavorite.toggle()
            storage.upsert(receipt: expense)
            return Observable.combineLatest(
                dateManageEvent.asObservable(),
                Observable.just(currentState.expenseByMonth)
            ).map { (date, models) in
                Mutation.updateExpenseList(self.filterData(by: date, for: models))
            }
            
        case .cellDelete(let indexPath):
            let expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            storage.delete(receipt: expense)
            return Observable.combineLatest(
                dateManageEvent.asObservable(),
                Observable.just(currentState.expenseByMonth)
            ).map { (date, models) in
                Mutation.updateExpenseList(self.filterData(by: date, for: models))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateExpenseList(let models):
            newState.expenseByMonth = models
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let dateEvent = dateManageEvent
            .distinctUntilChanged()
            .flatMap { date in
            return self.loadData().map { models in
                return Mutation.updateExpenseList(self.filterData(by: date, for: models))
            }
        }
        
        return Observable.merge(mutation, dateEvent)
    }
}

extension ListViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .day)
    }
    
    private func filterData(by date: Date?, for data: [ReceiptSectionModel]) -> [ReceiptSectionModel] {
        let currentDate = DateFormatter.string(from: date ?? Date())
        
        return data.filter { sectionModel in
            return sectionModel.items.contains { expense in
                let expenseDate = DateFormatter.string(from: expense.receiptDate)
                
                return expenseDate == currentDate
            }
        }
    }
}
