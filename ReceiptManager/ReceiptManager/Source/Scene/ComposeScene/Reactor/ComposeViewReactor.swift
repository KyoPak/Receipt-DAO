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
        case imageAppend(Data)
        case imageDelete(IndexPath?)
    }
    
    enum Mutation {
        case loadData
        case imageDataAppend([Data])
        case imageDataDelete([Data])
    }
    
    struct State {
        var title: String
        var transitionType: TransitionType
        var expense: Receipt?
        var priceText: String
        var registerdImageDatas: [Data]
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage, expense: Receipt? = nil, transisionType: TransitionType) {
        self.storage = storage
        
        let titleText = transisionType == .modal ?
            ConstantText.registerTitle.localize() : ConstantText.editTitle.localize()
        var imageDatas = expense?.receiptData ?? []
        imageDatas.insert(Data(), at: .zero)
        
        initialState = State(
            title: titleText,
            transitionType: transisionType,
            expense: expense,
            priceText: NumberFormatter.numberDecimal(from: expense?.priceText ?? ""),
            registerdImageDatas: imageDatas
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
        case .imageAppend(let data):
            var currentDatas = currentState.registerdImageDatas
            currentDatas.append(data)
            return Observable.just(Mutation.imageDataAppend(currentDatas))
        case .imageDelete(let indexPath):
            guard let indexPath = indexPath else { return Observable.empty() }
            
            var currentDatas = currentState.registerdImageDatas
            currentDatas.remove(at: indexPath.row)
            return Observable.just(Mutation.imageDataDelete(currentDatas))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            break
        case .imageDataAppend(let datas), .imageDataDelete(let datas):
            newState.registerdImageDatas = datas
        }
        
        return newState
    }
}
