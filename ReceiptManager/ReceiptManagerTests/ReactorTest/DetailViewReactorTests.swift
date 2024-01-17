//
//  DetailViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
import RxTest
@testable import ReceiptManager

final class DetailViewReactorTests: XCTestCase {
    private let disposeBag = DisposeBag()
    private var mockExpenseRepository: ExpenseRepository!
    private var mockCurrencyRepository: CurrencyRepository!
    private var mockDateRepository: DateRepository!
    
    override func setUpWithError() throws {
        mockExpenseRepository = MockExpenseRepository()
        mockCurrencyRepository = MockCurrencyRepository()
        mockDateRepository = MockDateRepository()
    }

    override func tearDownWithError() throws {
        mockExpenseRepository = nil
        mockCurrencyRepository = nil
        mockDateRepository = nil
    }
    
    func test_viewWillAppearAction() {
        // Given
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository,
            item: mockExpense
        )
        
        // When
        reactor.action.onNext(.viewWillAppear)
        
        // Then
        XCTAssertEqual(reactor.currentState.expense, mockExpense)
        XCTAssertEqual(reactor.currentState.priceText, "100,000￦")
    }
    
    func test_shareButtonTappedAction() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository,
            item: mockExpense
        )
        
        // When - Virtual Time 100에 이벤트 방출
        scheduler
            .createHotObservable([
                .next(100, .shareButtonTapped)
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        // Then - Virtual Time 0에 created, subscribe 시행
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.shareExpense }
        }
        
        XCTAssertEqual(response.events.compactMap { $0.value.element }, [nil, mockExpense.receiptData, nil])
    }
    
    func test_editAction() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository,
            item: mockExpense
        )
        
        // When - Virtual Time 100에 이벤트 방출
        scheduler
            .createHotObservable([
                .next(100, .edit)
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        // Then - Virtual Time 0에 created, subscribe 시행
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.editExpense }
        }
        
        XCTAssertEqual(response.events.compactMap { $0.value.element }, [nil, mockExpense, nil])
    }
    
    func test_deleteAction() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository,
            item: mockExpense
        )
        
        // When
        /// Virtual Time 100에 이벤트 방출
        mockExpenseRepository.save(expense: mockExpense)
        
        scheduler
            .createHotObservable([
                .next(100, .delete)
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        // Then - Virtual Time 0에 created, subscribe 시행
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.deleteExpense }
        }
        
        XCTAssertEqual(response.events.compactMap { $0.value.element }.count, 2)
    }
}

private extension Receipt {
    static func mockExpense() -> Receipt {
        return Receipt(store: "테스트", priceText: "100000", product: "테스트Product", receiptData: [Data()])
    }
}
