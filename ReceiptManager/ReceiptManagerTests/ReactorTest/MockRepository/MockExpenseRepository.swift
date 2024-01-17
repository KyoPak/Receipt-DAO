//
//  MockExpenseRepository.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import RxSwift
@testable import ReceiptManager

final class MockExpenseRepository: ExpenseRepository {
    var saveEvent: PublishSubject<Receipt>
    
    init() {
        saveEvent = PublishSubject()
    }
    
    func fetchExpenses() -> Observable<[Receipt]> {
        return Observable.just([Receipt(), Receipt(), Receipt()])
    }
    
    func save(expense: Receipt) -> Observable<Receipt> {
        saveEvent.onNext(expense)
        return Observable.just(expense)
    }
    
    func delete(expense: Receipt) -> Observable<Receipt> {
        return Observable.just(expense)
    }
}
