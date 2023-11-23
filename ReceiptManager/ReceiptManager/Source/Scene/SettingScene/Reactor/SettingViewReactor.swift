//
//  SettingViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/23.
//

import ReactorKit

final class SettingViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
    }
    
    enum Mutation {
        case loadData([SettingSection])
    }
    
    struct State {
        var settingMenu: [SettingSection]
    }
    
    let initialState: State
    
    // Properties
    
    // Initializer
    
    init() {
        initialState = State(settingMenu: [])
    }

    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let settingMenu = SettingSection.configureSettings()
            return Observable.just(Mutation.loadData(settingMenu))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let menu):
            newState.settingMenu = menu
        }
        
        return newState
    }
}
