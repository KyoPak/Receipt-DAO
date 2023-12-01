//
//  CalendarViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/1/23.
//

import ReactorKit

final class CalendarViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var expenseByMonth: [ReceiptSectionModel]
        var date: Date
        var days: [String]
    }
    
    let initialState: State
    
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
        initialState = State(expenseByMonth: [], date: Date(), days: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}
