//
//  MockStoragService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import RxSwift
@testable import ReceiptManager

final class MockStoragService: StorageService {
    private var receipts: [Receipt] = [Receipt(), Receipt(), Receipt()]
    
    func sync() { }
    
    func fetch() -> Observable<[Receipt]> {
        return Observable.just(receipts)
    }
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        if receipt.priceText == "-1" { // TriggerError
            return Observable.error(MockStorageError.receiptNotFound)
        }

        
        for index in 0..<receipts.count {
            if receipts[index].identity == receipt.identity {
                receipts.remove(at: index)
                break
            }
        }
        
        receipts.append(receipt)
        return Observable.just(receipt)
    }
    
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
