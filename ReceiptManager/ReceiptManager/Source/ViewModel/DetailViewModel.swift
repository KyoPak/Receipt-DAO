//
//  DetailViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation

final class DetailViewModel: CommonViewModel {
    var receipt: Receipt
    
    init(receipt: Receipt,
         title: String,
         sceneCoordinator: SceneCoordinator,
         storage: ReceiptStorage
    ) {
        self.receipt = receipt
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
}
