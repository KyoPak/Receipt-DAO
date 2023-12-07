//
//  CalendarListReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import ReactorKit

final class CalendarListReactor: Reactor {
    
    // Reactor Properties
    
    enum Action { 
        case loadView
        case cellBookMark(IndexPath)
        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case updateDateTitle(String)
        case updateExpenseList([Receipt])
    }
    
    struct State {
        var dateTitle: String
        var day: String
        var weekIndex: Int
        var expenseByDay: [Receipt]
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let dateManageService: DateManageService
    let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        weekIndex: Int
    ) {
        self.storage = storage
        self.userDefaultEvent = userDefaultService.event
        self.dateManageService = dateManageService
        
        initialState = State(dateTitle: "", day: day, weekIndex: weekIndex % 7, expenseByDay: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { 
        switch action {
        case .loadView:
            return Observable.concat([
                Observable.just(Mutation.updateDateTitle(updateDate())),
                loadData().map({ models in
                    Mutation.updateExpenseList(models)
                })
            ])
            
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByDay[indexPath.row]
            expense.isFavorite.toggle()
            storage.upsert(receipt: expense)
            return loadData().map { models in
                Mutation.updateExpenseList(models)
            }
            
        case .cellDelete(let indexPath):
            let expense = currentState.expenseByDay[indexPath.row]
            storage.delete(receipt: expense)
            return loadData().map { models in
                Mutation.updateExpenseList(models)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateDateTitle(let title):
            newState.dateTitle = title
        
        case .updateExpenseList(let models):
            newState.expenseByDay = models
        }
        
        return newState
    }
}

extension CalendarListReactor {
    private func loadData() -> Observable<[Receipt]> {
        let dayFormat = ConstantText.dateFormatFull.localize()
        let currentDate = updateDate()
        
        return storage.fetch()
            .distinctUntilChanged()
            .map { result in
                return result.filter { expense in
                    let expenseDate = DateFormatter.string(from: expense.receiptDate, dayFormat)
                    return expenseDate == currentDate
                }
            }
    }
}

extension CalendarListReactor {
    private func updateDate() -> String {
        let day = currentState.day
        let date = (try? dateManageService.currentDateEvent.value()) ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ConstantText.dateFormatMonth.localize()
            
        let yearMonthFormat = dateFormatter.string(from: date)
        dateFormatter.dateFormat = ConstantText.dateFormatDay.localize()
        let dayFormat = dateFormatter.string(from: dateFormatter.date(from: day) ?? Date())
            
        return "\(yearMonthFormat) \(dayFormat)"
    }
}
