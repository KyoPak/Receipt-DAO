//
//  ExpenseRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol ExpenseRepository {
    var saveEvent: PublishSubject<Receipt> { get }
    
    func fetch() -> Observable<[Receipt]>
    @discardableResult
    func save(exepnse: Receipt) -> Observable<Receipt>
    @discardableResult
    func delete(exepnse: Receipt) -> Observable<Receipt>
}

final class DefaultExpenseRepository: ExpenseRepository {
    private let service: StorageService
    let saveEvent: PublishSubject<Receipt>
    
    init(service: StorageService) {
        self.service = service
        saveEvent = PublishSubject()
    }
    
    func fetch() -> Observable<[Receipt]> {
        return service.fetch()
    }
    
    @discardableResult
    func save(exepnse: Receipt) -> Observable<Receipt> {
        saveEvent.onNext(exepnse)
        return service.upsert(receipt: exepnse)
    }
    
    @discardableResult
    func delete(exepnse: Receipt) -> Observable<Receipt> {
        return service.delete(receipt: exepnse)
    }
}
