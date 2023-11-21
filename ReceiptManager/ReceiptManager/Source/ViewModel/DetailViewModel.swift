//
//  DetailViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import RxSwift
import RxCocoa

protocol ComposeDataUpdatable: AnyObject {
    func update(receipt: Receipt)
}

final class DetailViewModel: CommonViewModel {
    private let disposeBag = DisposeBag()
    private let currencyValue: Int
    let currency: String
    var receipt: BehaviorSubject<Receipt>
    
    init(receipt: Receipt,
         title: String,
         sceneCoordinator: SceneCoordinator,
         storage: ReceiptStorage
    ) {
        self.receipt = BehaviorSubject<Receipt>(value: receipt)
        currencyValue = UserDefaults.standard.integer(forKey: ConstantText.currencyKey)
        currency = Currency(rawValue: currencyValue)?.description ?? Currency.KRW.description
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    func delete() {
        let receipt = (try? receipt.value()) ?? Receipt()
        
        storage.delete(receipt: receipt)
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
//    func makeEditAction() {
//        let receipt = (try? receipt.value()) ?? Receipt()
//
//        let composeViewModel = ComposeViewModel(
//            title: ConstantText.edit.localize(),
//            sceneCoordinator: sceneCoordinator,
//            storage: storage,
//            receipt: receipt,
//            delegate: self,
//            ocrExtractor: OCRTextExtractor()
//        )
//
//        let composeScene = Scene.compose(composeViewModel)
//        sceneCoordinator.transition(to: composeScene, using: .push, animated: true)
//    }
}

extension DetailViewModel: ComposeDataUpdatable {
    func update(receipt: Receipt) {
        self.receipt.onNext(receipt)
    }
}
