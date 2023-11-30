//
//  ReceiptStorage.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import RxSwift

protocol ReceiptStorage {
    var updateEvent: PublishSubject<Receipt> { get }
    
    func sync()
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func fetch() -> Observable<[Receipt]>
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt>
}
