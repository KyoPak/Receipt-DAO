//
//  CalendarCellReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/3/23.
//

import ReactorKit

final class CalendarCellReactor: Reactor {
    
    // Reactor Properties
    
    enum Action { }
    
    enum Mutation {
        case updateCurrency(Int)
    }
    
    struct State {
        var day: String
        var count: String
        var amount: String
        var isToday: Bool
        var currencyIndex: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let userDefaultEvent: BehaviorSubject<Int>
        
    // Initializer
    
    init(day: String, count: String, amount: String, isToday: Bool, userDefaultEvent: BehaviorSubject<Int>) {
        initialState = State(
            day: day,
            count: count,
            amount: NumberFormatter.numberDecimal(from: amount),
            isToday: isToday,
            currencyIndex: (try? userDefaultEvent.value()) ?? .zero
        )
        self.userDefaultEvent = userDefaultEvent
        
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateCurrency(let index):
            newState.currencyIndex = index
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return userDefaultEvent
            .flatMap { Observable.just(Mutation.updateCurrency($0)) }
    }
}
