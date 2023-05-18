//
//  ComposeViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxCocoa
import RxSwift

final class ComposeViewModel: CommonViewModel {
    private weak var updateDelegate: ComposeDataUpdatable?
    
    private let disposeBag = DisposeBag()
    
    var receipt: BehaviorSubject<Receipt>
    
    var receiptData = BehaviorSubject<[Data]>(value: [])
    
    init(
        title: String,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage,
        receipt: Receipt = Receipt(),
        delegate: ComposeDataUpdatable? = nil
    ) {
        self.receipt = BehaviorSubject(value: receipt)
        receiptData = BehaviorSubject(value: receipt.receiptData)
        updateDelegate = delegate
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }

    func addReceiptData(_ data: Data?) {
        guard let data = data else { return }
        
        var currentReceiptData = (try? receiptData.value()) ?? []   // 현재의 receiptData를 가져옴
        currentReceiptData.append(data)                // 새로운 데이터를 추가
        receiptData.onNext(currentReceiptData)
    }
    
    func cancelAction() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func saveAction() {
        var receiptData = (try? self.receiptData.value()) ?? []
        receiptData.removeFirst()
        
        var receipt = (try? receipt.value()) ?? Receipt()
        receipt.receiptData = receiptData
        
        storage.upsert(receipt: receipt)
        updateDelegate?.update(receipt: receipt)
        cancelAction()
    }
}
