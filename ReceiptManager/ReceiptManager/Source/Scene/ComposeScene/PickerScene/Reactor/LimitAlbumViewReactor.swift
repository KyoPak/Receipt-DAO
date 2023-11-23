//
//  LimitAlbumViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/22.
//

import ReactorKit
import RxSwift
import RxCocoa

protocol SelectPickerImageDelegate: AnyObject {
    func selectImagePicker(datas: [Data])
}

final class LimitAlbumViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case loadImageData(Data?)
        case imageSelected(IndexPath)
        case imageDeselected(IndexPath)
        case selectCompleteButtonTapped
        case initialData
    }
    
    enum Mutation {
        case appendLimitedImageData([Data])
        case handleSelectedImageData([Data], IndexPath)
        case sendSelectImageDatas(Void?)
        case initialState(State)
    }
    
    struct State {
        var limitedImagesData: [Data]
        var selectedImageData: [Data]
        var handleIndex: IndexPath?
        var sendData: Void?
        var currentImageCount: Int
    }
    
    let initialState: State
    
    // Properties
    
    private weak var delegate: SelectPickerImageDelegate?
    
    // Initializer
    
    init(delegate: SelectPickerImageDelegate, imageCount: Int) {
        self.delegate = delegate
        initialState = State(
            limitedImagesData: [],
            selectedImageData: [],
            handleIndex: nil,
            sendData: nil,
            currentImageCount: imageCount
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadImageData(let data):
            var currentDatas = currentState.limitedImagesData
            currentDatas.append(data ?? Data())
            return Observable.just(Mutation.appendLimitedImageData(currentDatas))
            
        case .imageSelected(let indexPath):
            var currentDatas = currentState.selectedImageData
            if currentDatas.count >= 5 - currentState.currentImageCount {
                return Observable.empty()
            }
            currentDatas.append(currentState.limitedImagesData[indexPath.item])
            
            return Observable.just(Mutation.handleSelectedImageData(currentDatas, indexPath))
            
        case .imageDeselected(let indexPath):
            let removeData = currentState.limitedImagesData[indexPath.item]
            guard let removeIndex = currentState.selectedImageData.firstIndex(of: removeData) else {
                return Observable.empty()
            }
            var currentDatas = currentState.selectedImageData
            currentDatas.remove(at: removeIndex)

            return Observable.just(Mutation.handleSelectedImageData(currentDatas, indexPath))
            
        case .selectCompleteButtonTapped:
            delegate?.selectImagePicker(datas: currentState.selectedImageData)
            return Observable.just(Mutation.sendSelectImageDatas(Void()))
            
        case .initialData:
            let state = State(
                limitedImagesData: [],
                selectedImageData: [],
                currentImageCount: currentState.currentImageCount
            )
            return Observable.just(Mutation.initialState(state))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .appendLimitedImageData(let datas):
            newState.limitedImagesData = datas
            
        case .handleSelectedImageData(let datas, let indexPath):
            newState.selectedImageData = datas
            newState.handleIndex = indexPath
            
        case .sendSelectImageDatas(let void):
            newState.sendData = void
            
        case .initialState(let initialState):
            newState = initialState
        }
        
        return newState
    }
}
