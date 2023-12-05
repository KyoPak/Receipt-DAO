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
        
    }
    
    let initialState: State
    
    // Properties
        
    // Initializer
    
    init() {
        initialState = State()
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        
        
    }
}
