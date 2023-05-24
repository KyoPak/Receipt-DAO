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
    
    init(
        title: String,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage,
        receipt: Receipt = Receipt(),
        delegate: ComposeDataUpdatable? = nil
    ) {
        self.receipt = BehaviorSubject(value: receipt)
        updateDelegate = delegate
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }

    func updateReceiptData(_ data: Data?, isFirstReceipt: Bool) {
        guard let data = data else { return }
        
        var currentReceipt = (try? receipt.value()) ?? Receipt()
        var currentReceiptData = currentReceipt.receiptData
        
        if isFirstReceipt {
            currentReceiptData.insert(data, at: .zero)
        } else {
            currentReceiptData.append(data)
        }
        
        currentReceipt.receiptData = currentReceiptData
        receipt.onNext(currentReceipt)
    }
    
    func deleteReceiptData(indexPath: IndexPath) {
        var currentReceipt = (try? receipt.value()) ?? Receipt()
        var currentReceiptData = currentReceipt.receiptData
        
        currentReceiptData.remove(at: indexPath.item)
        
        currentReceipt.receiptData = currentReceiptData
        receipt.onNext(currentReceipt)
    }
    
    func cancelAction(completion: (() -> Void)? = nil) {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
        
        completion?()
    }
    
    func saveAction() {
        var currentReceipt = (try? receipt.value()) ?? Receipt()
        
        var currentReceiptData = currentReceipt.receiptData
        currentReceiptData.removeFirst()
        
        currentReceipt.receiptData = currentReceiptData
        receipt.onNext(currentReceipt)
        
        storage.upsert(receipt: currentReceipt)
        updateDelegate?.update(receipt: currentReceipt)
        cancelAction()
    }
    
    func selectImageAction(selectDatas: [Data], delegate: SelectPickerDelegate) {
        // count는 현재 등록된 이미지 갯수.
        let currentReceipt = (try? receipt.value()) ?? Receipt()
        let currentReceiptData = currentReceipt.receiptData
        
        let selectImageViewModel = SelectImageViewModel(
            title: ConstantText.selectImage,
            sceneCoordinator: sceneCoordinator,
            storage: storage,
            data: selectDatas,
            count: 6 - currentReceiptData.count,
            pickerDelegate: delegate,
            selectCompleteDelegate: self
        )
        
        let selectImageScene = Scene.selectImage(selectImageViewModel)
        
        sceneCoordinator.transition(to: selectImageScene, using: .modalNavi, animated: true)
    }
}

extension ComposeViewModel: SelectCompletable {
    func selectComplete(datas: [Data]) {
        var currentReceipt = (try? receipt.value()) ?? Receipt()
        var currentReceiptData = currentReceipt.receiptData
        
        currentReceiptData.append(contentsOf: datas)
        currentReceipt.receiptData = currentReceiptData
        receipt.onNext(currentReceipt)
    }
}
