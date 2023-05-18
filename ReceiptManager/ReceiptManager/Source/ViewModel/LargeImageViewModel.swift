//
//  LargeImageViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/18.
//

import Foundation
import RxSwift
import RxCocoa

final class LargeImageViewModel: CommonViewModel {
    var data: Observable<Data>
    
    private let disposeBag = DisposeBag()
    
    init(
        title: String,
        data: Data,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage
    ) {
        self.data = Observable<Data>.just(data)
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    func closeView() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
