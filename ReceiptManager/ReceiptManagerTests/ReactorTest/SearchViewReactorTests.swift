//
//  SearchViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class SearchViewReactorTests: XCTestCase {
    private var mockExpenseRepository: ExpenseRepository!
    private var mockUserSettingRepository: UserSettingRepository!
    private var mockDateRepository: DateRepository!
    
    override func setUpWithError() throws {
        mockExpenseRepository = MockExpenseRepository()
        mockUserSettingRepository = MockUserSettingRepository()
        mockDateRepository = MockDateRepository()
    }

    override func tearDownWithError() throws {
        mockExpenseRepository = nil
        mockUserSettingRepository = nil
        mockDateRepository = nil
    }
    
    func test_loadDataAction() {
        // Given
        let reactor = SearchViewReactor(
            expenseRepository: mockExpenseRepository,
            userSettingRepository: mockUserSettingRepository
        )
        let targetText = "Test"
        mockExpenseRepository.save(expense: Receipt(store: targetText))
        mockExpenseRepository.save(expense: Receipt(product: targetText))
        mockExpenseRepository.save(expense: Receipt(memo: targetText))
        
        // When
        reactor.action.onNext(.searchExpense(targetText))
        
        // Then
        XCTAssertEqual(reactor.currentState.searchText, targetText)
        XCTAssertEqual(reactor.currentState.searchResult.first?.items.count, 3)
    }
}
