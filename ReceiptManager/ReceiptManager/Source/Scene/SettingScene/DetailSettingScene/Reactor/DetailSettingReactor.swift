//
//  DetailSettingReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import ReactorKit

final class DetailSettingReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        case cellSelect(IndexPath)
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
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
