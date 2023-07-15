//
//  CommonViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import RxSwift
import RxCocoa

class CommonViewModel {
    let title: Driver<String>
    let sceneCoordinator: SceneCoordinator
    let storage: ReceiptStorage
    
    init(title: String, sceneCoordinator: SceneCoordinator, storage: ReceiptStorage) {
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.sceneCoordinator = sceneCoordinator
        self.storage = storage
    }
}
