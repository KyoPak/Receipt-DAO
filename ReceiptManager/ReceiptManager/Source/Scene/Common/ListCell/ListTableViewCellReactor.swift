//
//  ListTableViewCellReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import ReactorKit

final class ListTableViewCellReactor: Reactor {
    
    // Reactor Properties
    
    enum Action { }
    
    enum Mutation {
        case updateCurrency(Int)
    }
    
    struct State {
        var expense: Receipt
        var currency: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(expense: Receipt, userDefaultEvent: BehaviorSubject<Int>) {
        initialState = State(expense: expense, currency: (try? userDefaultEvent.value()) ?? .zero)
        self.userDefaultEvent = userDefaultEvent
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateCurrency(let index):
            newState.currency = index
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return userDefaultEvent
            .flatMap { Observable.just(Mutation.updateCurrency($0)) }
    }
}
