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

    }
    
    enum Mutation {
        
    }
    
    struct State {
        var dateTitle: String
        var day: String
        var expenses: [Receipt]
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
        
        initialState = State(dateTitle: "", day: day, expenses: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        
        
    }
}
