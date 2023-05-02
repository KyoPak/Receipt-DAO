//
//  CommonViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel {
    let title: Driver<String>
    
    let storage: ReceiptStorage
    
    init(title: String, storage: ReceiptStorage) {
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.storage = storage
    }
}
