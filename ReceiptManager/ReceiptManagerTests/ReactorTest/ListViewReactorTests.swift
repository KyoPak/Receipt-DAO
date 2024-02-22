//
//  ListViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class ListViewReactorTests: XCTestCase {
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
        let reactor = ListViewReactor(
            expenseRepository: mockExpenseRepository,
            userSettingRepository: mockUserSettingRepository,
            dateRepository: mockDateRepository
        )
        
        // When
        reactor.action.onNext(.loadData)
        
        // Then
        XCTAssertEqual(reactor.currentState.expenseByMonth.count, 1)
        XCTAssertEqual(reactor.currentState.expenseByMonth.first?.items.count, 3)
    }
    
    func test_cellBookMarkAction() {
        // Given
        let reactor = ListViewReactor(
            expenseRepository: mockExpenseRepository,
            userSettingRepository: mockUserSettingRepository,
            dateRepository: mockDateRepository
        )
        
        // When
        reactor.action.onNext(.cellBookMark(IndexPath(row: .zero, section: .zero)))
        
        // Then
        let result = reactor.currentState.expenseByMonth.first?.items.last?.isFavorite ?? false
        XCTAssertEqual(result, true)
    }
    
    func test_cellDeleteAction() {
        // Given
        let reactor = ListViewReactor(
            expenseRepository: mockExpenseRepository,
            userSettingRepository: mockUserSettingRepository,
            dateRepository: mockDateRepository
        )
        
        // When
        reactor.action.onNext(.loadData)
        reactor.action.onNext(.cellDelete(IndexPath(item: .zero, section: .zero)))
        
        // Then
        XCTAssertEqual(reactor.currentState.expenseByMonth.first?.items.count, 2)
    }
    
    func test_dateEventChange() {
        // Given
        let reactor = ListViewReactor(
            expenseRepository: mockExpenseRepository,
            userSettingRepository: mockUserSettingRepository,
            dateRepository: mockDateRepository
        )
        
        reactor.action.onNext(.loadData)
        let nextDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date()
        
        // When
        mockDateRepository.changeDate(byAddingMonths: 1)
        reactor.action.onNext(.loadData)
        
        // Then
        XCTAssertEqual(reactor.currentState.expenseByMonth.count, .zero)
        XCTAssertNil(reactor.currentState.expenseByMonth.first?.items.count)
        XCTAssertEqual(reactor.currentState.date.description, nextDate.description)
    }
}
