//
//  ExpenseRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol ExpenseRepository {
    var saveEvent: PublishSubject<Receipt> { get }
    
    func fetchExpenses() -> Observable<[Receipt]>
    @discardableResult
    func save(expense: Receipt) -> Observable<Receipt>
    @discardableResult
    func delete(expense: Receipt) -> Observable<Receipt>
}

final class DefaultExpenseRepository: ExpenseRepository {
    private let service: StorageService
    let saveEvent: PublishSubject<Receipt>
    
    init(service: StorageService) {
        self.service = service
        saveEvent = PublishSubject()
    }
    
    func fetchExpenses() -> Observable<[Receipt]> {
        return service.fetch()
    }
    
    @discardableResult
    func save(expense: Receipt) -> Observable<Receipt> {
        saveEvent.onNext(expense)
        return service.upsert(receipt: expense)
    }
    
    @discardableResult
    func delete(expense: Receipt) -> Observable<Receipt> {
        return service.delete(receipt: expense)
    }
}
