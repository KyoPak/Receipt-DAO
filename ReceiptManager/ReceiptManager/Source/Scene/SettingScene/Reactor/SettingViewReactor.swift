//
//  SettingViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/23.
//

import ReactorKit
import RxSwift
import RxCocoa

final class SettingViewReactor: Reactor {
    
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
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }

    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
