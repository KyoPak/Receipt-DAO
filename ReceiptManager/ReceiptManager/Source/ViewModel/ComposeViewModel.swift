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
    
    private var originalReceipt: Receipt
    
    var dateRelay: BehaviorRelay<Date>
    var storeRelay: BehaviorRelay<String>
    var productRelay: BehaviorRelay<String>
    var priceRelay: BehaviorRelay<Int>
    var memoRelay: BehaviorRelay<String>
    var payRelay: BehaviorRelay<Int>
    var receiptDataRelay: BehaviorRelay<[Data]>

    var ocrExtractor: OCRTextExtractable
    
    init(
        title: String,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage,
        receipt: Receipt = Receipt(),
        delegate: ComposeDataUpdatable? = nil,
        ocrExtractor: OCRTextExtractable
    ) {
        originalReceipt = receipt
        
        dateRelay = BehaviorRelay(value: receipt.receiptDate)
        storeRelay = BehaviorRelay(value: receipt.store)
        productRelay = BehaviorRelay(value: receipt.product)
        priceRelay = BehaviorRelay(value: receipt.price)
        memoRelay = BehaviorRelay(value: receipt.memo)
        payRelay = BehaviorRelay(value: receipt.paymentType)
        receiptDataRelay = BehaviorRelay(value: receipt.receiptData)
        
        updateDelegate = delegate
        self.ocrExtractor = ocrExtractor
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    private func bindOCRExtractor() {
        ocrExtractor.ocrResult
            .bind { [weak self] ocrResult in
                self?.dateRelay.accept(ocrResult.date)
                self?.storeRelay.accept(ocrResult.store)
                self?.priceRelay.accept(ocrResult.price)
                self?.payRelay.accept(ocrResult.paymentType)
            }
            .disposed(by: disposeBag)
    }
}

extension ComposeViewModel {
    func updateReceiptData(_ data: Data?, isFirstReceipt: Bool) {
        guard let data = data else { return }
        
        var currentReceiptData = receiptDataRelay.value
        
        if isFirstReceipt {
            currentReceiptData.insert(data, at: .zero)
        } else {
            // 첫번째 이미지 OCR 로직 동작
            if #available(iOS 16.0, *), currentReceiptData.count == 1 {
                bindOCRExtractor()
                ocrExtractor.extractText(data: data)
            }
            
            currentReceiptData.append(data)
        }
        
        receiptDataRelay.accept(currentReceiptData)
    }
    
    func deleteReceiptData(indexPath: IndexPath) {
        var currentReceiptData = receiptDataRelay.value
        
        currentReceiptData.remove(at: indexPath.item)
        receiptDataRelay.accept(currentReceiptData)
    }
    
    func cancelAction(completion: (() -> Void)? = nil) {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
        
        completion?()
    }
    
    func saveAction() {
        var currentReceiptData = receiptDataRelay.value
        currentReceiptData.removeFirst()
        
        receiptDataRelay.accept(currentReceiptData)
        
        var newReceipt = originalReceipt
        
        newReceipt.product = productRelay.value
        newReceipt.price = priceRelay.value
        newReceipt.memo = memoRelay.value
        newReceipt.paymentType = payRelay.value
        newReceipt.store = storeRelay.value
        newReceipt.receiptData = receiptDataRelay.value
        newReceipt.receiptDate = dateRelay.value
        
        storage.upsert(receipt: newReceipt)
        updateDelegate?.update(receipt: newReceipt)
        cancelAction()
    }
    
    func selectImageAction(selectDatas: [Data], delegate: SelectPickerDelegate) {
        // count는 현재 등록된 이미지 갯수
        let currentReceiptData = receiptDataRelay.value
        
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
        var currentReceiptData = receiptDataRelay.value
        
        currentReceiptData.append(contentsOf: datas)
        receiptDataRelay.accept(currentReceiptData)
    }
}
