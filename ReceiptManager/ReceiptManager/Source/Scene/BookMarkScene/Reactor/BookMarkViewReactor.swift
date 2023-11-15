//
//  BookMarkViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit
import RxSwift
import RxCocoa

final class BookMarkViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    let initialState = State()
    
    private let storage: CoreDataStorage
    
    init(stoage: CoreDataStorage) {
        self.storage = storage
    }

    func mutate(action: Action) -> Observable<Mutation> {
        
    }

    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
