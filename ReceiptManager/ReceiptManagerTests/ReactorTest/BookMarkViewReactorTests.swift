//
//  BookMarkViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class BookMarkViewReactorTests: XCTestCase {
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
        let mockExpense1 = Receipt.mockExpense()
        let mockExpense2 = Receipt.mockExpense()
        mockExpenseRepository.save(expense: mockExpense1)
        mockExpenseRepository.save(expense: mockExpense2)
        
        let reactor = BookMarkViewReactor(
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository
        )
            
        // When
        reactor.action.onNext(.viewWillAppear)
        
        // Then
        XCTAssertEqual(reactor.currentState.expenseByBookMark.first?.items.count, 2)
    }
    
    func test_cellUnBookMarkAction() {
        // Given
        let mockExpense1 = Receipt.mockExpense()
        let mockExpense2 = Receipt.mockExpense()
        mockExpenseRepository.save(expense: mockExpense1)
        mockExpenseRepository.save(expense: mockExpense2)
        
        let reactor = BookMarkViewReactor(
            expenseRepository: mockExpenseRepository,
            currencyRepository: mockCurrencyRepository
        )
        
        // When
        reactor.action.onNext(.viewWillAppear)
        reactor.action.onNext(.cellUnBookMark(IndexPath(item: .zero, section: .zero)))
        
        // Then
        XCTAssertEqual(reactor.currentState.expenseByBookMark.first?.items.count, 1)
    }
}

private extension Receipt {
    static func mockExpense() -> Receipt {
        return Receipt(store: "테스트", priceText: "100000", product: "테스트Product", isFavorite: true)
    }
}
