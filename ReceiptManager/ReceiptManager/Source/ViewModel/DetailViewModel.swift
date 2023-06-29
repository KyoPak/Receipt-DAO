//
//  DetailViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxCocoa

protocol ComposeDataUpdatable: AnyObject {
    func update(receipt: Receipt)
}

final class DetailViewModel: CommonViewModel {
    var receipt: BehaviorSubject<Receipt>
    private let disposeBag = DisposeBag()
    
    init(receipt: Receipt,
         title: String,
         sceneCoordinator: SceneCoordinator,
         storage: ReceiptStorage
    ) {
        self.receipt = BehaviorSubject<Receipt>(value: receipt)
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    func delete() {
        let receipt = (try? receipt.value()) ?? Receipt()
        
        storage.delete(receipt: receipt)
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func makeEditAction() {
        let receipt = (try? receipt.value()) ?? Receipt()
        
        let composeViewModel = ComposeViewModel(
            title: ConstantText.edit.localize(),
            sceneCoordinator: sceneCoordinator,
            storage: storage,
            receipt: receipt,
            delegate: self,
            ocrExtractor: OCRTextExtractor()
        )
        
        let composeScene = Scene.compose(composeViewModel)
        sceneCoordinator.transition(to: composeScene, using: .push, animated: true)
    }
    
    func largeImageAction(data: Data) {
        let largeImageViewModel = LargeImageViewModel(
            title: "",
            data: data,
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let largeImageView = Scene.large(largeImageViewModel)
        sceneCoordinator.transition(to: largeImageView, using: .modal, animated: true)
    }
}

extension DetailViewModel: ComposeDataUpdatable {
    func update(receipt: Receipt) {
        self.receipt.onNext(receipt)
    }
}
