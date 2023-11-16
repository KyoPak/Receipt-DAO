//
//  DetailViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit
import RxSwift
import RxCocoa

final class DetailViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case optionButtonTapped
        case shareButtonTapped
        case imageTapped
        case imageSwipe
    }
    
    enum Mutation {

    }
    
    struct State {
        var expense: Receipt
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage, item: Receipt) {
        self.storage = storage
        initialState = State(expense: item)
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
