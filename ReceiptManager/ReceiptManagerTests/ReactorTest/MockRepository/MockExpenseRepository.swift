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
    private var datas: [Receipt] = [Receipt(), Receipt(), Receipt()]
    
    init() {
        saveEvent = PublishSubject()
    }
    
    func fetchExpenses() -> Observable<[Receipt]> {
        return Observable.just(datas)
    }
    
    func save(expense: Receipt) -> Observable<Receipt> {
        var updateFlag = false
        for data in datas {
            if data.identity == expense.identity {
                var index = datas.firstIndex(of: data)!
                datas.remove(at: index)
                datas.append(expense)
                updateFlag = true
            }
        }
        
        if !updateFlag { datas.append(expense) }
        
        saveEvent.onNext(expense)
        return Observable.just(expense)
    }
    
    func delete(expense: Receipt) -> Observable<Receipt> {
        var deleteFlag = false
        
        for data in datas {
            if data.identity == expense.identity {
                var index = datas.firstIndex(of: data)!
                datas.remove(at: index)
                deleteFlag = true
                break
            }
        }
        
        if !deleteFlag { return Observable.error(MockExpenseRepositoryError.deleteError) }
        
        return Observable.just(expense)
    }
}

enum MockExpenseRepositoryError: Error {
    case deleteError
}
