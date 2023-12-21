//
//  MockStoragService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import RxSwift
@testable import ReceiptManager

final class MockStoragService: StorageService {
    var updateEvent = PublishSubject<Receipt>()
    
    private var receipts: [Receipt] = [Receipt(), Receipt(), Receipt()]
    
    func sync() { }
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        for index in 0..<receipts.count {
            if receipts[index].identity == receipt.identity {
                receipts.remove(at: index)
                break
            }
        }
        
        updateEvent.onNext(receipt)
        receipts.append(receipt)
        return Observable.just(receipt)
    }
    
    @discardableResult
    func fetch() -> Observable<[Receipt]> {
        return Observable.just(receipts)
    }
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt> {
        if let index = receipts.firstIndex(where: { $0 == receipt }) {
            receipts.remove(at: index)
            return Observable.just(receipt)
        } else {
            return Observable.error(MockStorageError.receiptNotFound)
        }
    }
}

enum MockStorageError: Error {
    case receiptNotFound
}
