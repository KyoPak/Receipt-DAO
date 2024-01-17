//
//  ExpenseRepositoryTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class ExpenseRepositoryTests: XCTestCase {
    private var service: StorageService!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        service = MockStoragService()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        service = nil
        disposeBag = nil
    }
    
    func test_fetch() {
        // Given
        let repository = DefaultExpenseRepository(service: service)
        let answerCount = 3
        
        // When
        let result = repository.fetchExpenses()
        
        // Then
        result.subscribe { datas in
            XCTAssertEqual(answerCount, datas.count)
        } onError: { error in
            XCTFail(error.localizedDescription)
        }
        .disposed(by: disposeBag)
    }
    
    func test_save() {
        // Given
        let targetExpense = Receipt()
        let repository = DefaultExpenseRepository(service: service)
        
        // When
        let result = repository.save(expense: targetExpense)
        
        // Then
        result.subscribe { data in
            XCTAssertEqual(targetExpense, data)
        }
        .disposed(by: disposeBag)
    }
    
    func test_save_when_error() {
        // Given
        let targetExpense = Receipt(priceText: "-1")
        let repository = DefaultExpenseRepository(service: service)
        
        // When
        let result = repository.save(expense: targetExpense)
        
        // Then
        result.subscribe { data in
            XCTFail("Expect Error")
        } onError: { error in
            XCTAssert(true)
        }
        .disposed(by: disposeBag)
    }
    
    func test_delete() {
        // Given
        var targetExpense = Receipt()
        let repository = DefaultExpenseRepository(service: service)
        
        // When
        repository.fetchExpenses()
            .subscribe { datas in
                targetExpense = datas.first!
            }
            .disposed(by: disposeBag)
        
        let result = repository.delete(expense: targetExpense)
        
        // Then
        result.subscribe { data in
            XCTAssertEqual(targetExpense, data)
        } onError: { error in
            XCTFail()
        }
        .disposed(by: disposeBag)
    }
    
    func test_delete_when_error() {
        // Given
        let targetExpense = Receipt()
        let repository = DefaultExpenseRepository(service: service)
        
        // When
        let result = repository.delete(expense: targetExpense)
        
        // Then
        result.subscribe { data in
            XCTFail("Expect Error")
        } onError: { error in
            XCTAssert(true)
        }
        .disposed(by: disposeBag)
    }
}
