//
//  MainViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit

final class MainViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case registerButtonTapped
        case searchButtonTapped
        case showModeButtomTapped
    }
    
    enum Mutation {
        case moveRegister
        case moveSearch
        case changeShowMode
    }
    
    struct State {
        var title: String
        var isRegister: Bool
        var isSearch: Bool
        var showMode: ShowMode
    }
    
    enum ShowMode {
        case calendar
        case list
    }
    
    let initialState = State(
        title: ConstantText.list.localize(), isRegister: false, isSearch: false, showMode: .list
    )
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }

    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .registerButtonTapped:
            return .just(.moveRegister)
        case .searchButtonTapped:
            return .just(.moveSearch)
        case .showModeButtomTapped:
            return .just(.changeShowMode)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .moveRegister:
            newState.isRegister = true
        case .moveSearch:
            newState.isSearch = true
        case .changeShowMode:
            newState.showMode = (newState.showMode == .calendar) ? .list : .calendar
        }

        return newState
    }
}
