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
    func create(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func fetch() -> Observable<[Receipt]>
    
    @discardableResult
    func update(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt>
}
