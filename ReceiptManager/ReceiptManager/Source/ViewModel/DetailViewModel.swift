//
//  DetailViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: CommonViewModel {
    var receipt: Receipt
    var receiptData: BehaviorSubject<[Data]>
    
    init(receipt: Receipt,
         title: String,
         sceneCoordinator: SceneCoordinator,
         storage: ReceiptStorage
    ) {
        self.receipt = receipt
        receiptData = BehaviorSubject<[Data]>(value: receipt.receiptData)
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
}
