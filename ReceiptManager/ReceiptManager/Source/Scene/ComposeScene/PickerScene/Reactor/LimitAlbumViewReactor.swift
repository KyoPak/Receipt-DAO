//
//  LimitAlbumViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/22.
//

import ReactorKit
import RxSwift
import RxCocoa

final class LimitAlbumViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case loadImageData(Data?)
    }
    
    enum Mutation {
        case appendLimitedImageData(Data)
    }
    
    struct State {
        var limitedImagesData: [Data]
    }
    
    let initialState = State(limitedImagesData: [])
    
    // Properties
    
    // Initializer
    
    init() {
        
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadImageData(let data):
            return Observable.just(Mutation.appendLimitedImageData(data ?? Data()))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .appendLimitedImageData(let data):
            newState.limitedImagesData.append(data)
        }
        
        return newState
    }
}
