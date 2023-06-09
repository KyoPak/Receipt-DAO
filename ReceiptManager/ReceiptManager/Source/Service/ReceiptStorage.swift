//
//  ReceiptStorage.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation
import RxSwift

protocol ReceiptStorage {
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func fetch(type: FetchType) -> Observable<[ReceiptSectionModel]>
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt>
}
