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
    var memo: String?
    
    var receiptData = BehaviorSubject<[Data]>(value: [])
    
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
        self.memo = memo
        
        self.receiptData.onNext(receiptData)
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }

    func addReceiptData(_ data: Data?) {
        guard let data = data else { return }
        
        var currentReceiptData = (try? receiptData.value()) ?? []   // 현재의 receiptData를 가져옴
        currentReceiptData.append(data)                             // 새로운 데이터를 추가
        receiptData.onNext(currentReceiptData)                      // 변경된 receiptData를 알림
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
        var receiptData = (try? self.receiptData.value()) ?? []
        receiptData.removeFirst()
        
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
        
        storage.upsert(receipt: saveData)
        
        cancelAction()
    }
}
