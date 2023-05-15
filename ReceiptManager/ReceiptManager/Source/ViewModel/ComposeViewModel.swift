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
    private let disposeBag = DisposeBag()
    
    // 표기 목록
    var date: Date?
    var store: String?
    var product: String?
    var price: Int?
    var payType: PayType
    var receiptData: [Data]
    var memo: String?
    
    init(
        title: String,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage,
        date: Date = Date(),
        store: String? = nil,
        product: String? = nil,
        price: Int? = nil,
        payType: PayType = .cash,
        receiptData: [Data] = [],
        memo: String? = nil
    ) {
        self.date = date
        self.store = store
        self.product = product
        self.price = price
        self.payType = payType
        self.receiptData = receiptData
        self.memo = memo
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    func cancelAction() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func saveAction(
        store: String?,
        product: String?,
        price: Int?,
        date: Date?,
        payType: PayType,
        memo: String?,
        receiptData: [Data]
    ) {
        let saveData = Receipt(
            store: store ?? "",
            price: price ?? .zero,
            product: product ?? "",
            receiptDate: date ?? Date(),
            paymentType: payType.rawValue,
            receiptData: receiptData,
            memo: memo ?? "",
            isFavorite: false
        )
        print(saveData)
        storage.upsert(receipt: saveData)
        
        cancelAction()
    }
}
