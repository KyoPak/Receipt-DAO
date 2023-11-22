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
        case registerButtonTapped(SaveExpense)
    }
    
    enum Mutation {
        case loadData
        case imageDataAppend([Data])
        case imageDataDelete([Data])
        case saveExpense(Receipt)
    }
    
    struct State {
        var title: String
        var transitionType: TransitionType
        var expense: Receipt?
        var priceText: String
        var registerdImageDatas: [Data]
    }
    
    struct SaveExpense {
        var date: Date
        var store: String?
        var price: String?
        var product: String?
        var paymentType: Int
        var memo: String?
    }
    
    enum ControlType {
        case append(Data)
        case delete(Int)
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
            var currentDatas = controlImageData(controlType: .append(data))
            return Observable.just(Mutation.imageDataAppend(currentDatas))
        
        case .imageDelete(let indexPath):
            guard let indexPath = indexPath else { return Observable.empty() }
            var currentDatas = controlImageData(controlType: .delete(indexPath.row))
            
            return Observable.just(Mutation.imageDataDelete(currentDatas))
            
        case .registerButtonTapped(let saveExpense):
            let newExpense = convertExpense(saveExpense)
            return Observable.just(Mutation.saveExpense(newExpense))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            break
        case .imageDataAppend(let datas), .imageDataDelete(let datas):
            newState.registerdImageDatas = datas
            
        case .saveExpense(let data):
            storage.upsert(receipt: data)
        }
        
        return newState
    }
}

extension ComposeViewReactor {
    private func controlImageData(controlType: ControlType) -> [Data] {
        var currentDatas = currentState.registerdImageDatas
        
        switch controlType {
        case .append(let data):
            currentDatas.append(data)
        case .delete(let index):
            currentDatas.remove(at: index)
        }
        
        return currentDatas
    }
    
    private func convertExpense(_ data: SaveExpense) -> Receipt {
        var imageDatas = controlImageData(controlType: .delete(.zero))
        
        return Receipt(
            store: data.store ?? "", priceText: data.price ?? "",
            product: data.product ?? "", receiptDate: data.date,
            paymentType: data.paymentType, receiptData: imageDatas,
            memo: data.memo ?? "", isFavorite: false
        )
    }
}
