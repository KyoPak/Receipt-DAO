//
//  ComposeViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import ReactorKit
import RxSwift
import RxCocoa

final class ComposeViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
//        case saveButtonTapped
    }
    
    enum Mutation {
        case loadData
    }
    
    struct State {
        var title: String
        var transitionType: TransitionType
        var expense: Receipt?
        var priceText: String?
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage, expense: Receipt? = nil, transisionType: TransitionType) {
        self.storage = storage
        
        let titleText = transisionType == .modal ?
            ConstantText.registerTitle.localize() : ConstantText.editTitle.localize()
        
        initialState = State(
            title: titleText,
            transitionType: transisionType,
            expense: expense
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            break
        }
        
        return newState
    }
}
