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
//        case cellBookMark(IndexPath)
//        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case updateDateTitle(String)
        case updateExpenseList([ReceiptSectionModel])
    }
    
    struct State {
        var dateTitle: String
        var day: String
        var expenseByDay: [ReceiptSectionModel]
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
        day: String
    ) {
        self.storage = storage
        self.userDefaultEvent = userDefaultService.event
        self.dateManageService = dateManageService
        
        initialState = State(dateTitle: "", day: day, expenseByDay: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { 
        switch action {
        case .loadView:
            return Observable.just(Mutation.updateDateTitle(updateDateTitle()))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        switch mutation {
        case .updateDateTitle(let title):
            newState.dateTitle = title
        
        case .updateExpenseList(let array):
            break
        }
        
        return newState
    }
}

extension CalendarListReactor {
    private func updateDateTitle() -> String {
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
