//
//  ExpenseViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class ExpenseViewReactorTests: XCTestCase {
    private var dateRepository: DateRepository!
    
    override func setUpWithError() throws {
        dateRepository = MockDateRepository()
    }

    override func tearDownWithError() throws {
        dateRepository = nil
    }

    func test_nextMonthAction() {
        // Given
        let reactor = ExpenseViewReactor(dateRepository: dateRepository)
        let nextDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date()
        
        // When
        reactor.action.onNext(.nextMonthButtonTapped)
            
        // Then
        XCTAssertEqual(DateFormatter.year(from: reactor.currentState.dateToShow), DateFormatter.year(from: nextDate))
        XCTAssertEqual(DateFormatter.month(from: reactor.currentState.dateToShow), DateFormatter.month(from: nextDate))
    }
    
    func test_previousMonthAction() {
        // Given
        let reactor = ExpenseViewReactor(dateRepository: dateRepository)
        let nextDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: Date()) ?? Date()
        
        // When
        reactor.action.onNext(.previousMonthButtonTapped)
            
        // Then
        XCTAssertEqual(DateFormatter.year(from: reactor.currentState.dateToShow), DateFormatter.year(from: nextDate))
        XCTAssertEqual(DateFormatter.month(from: reactor.currentState.dateToShow), DateFormatter.month(from: nextDate))
    }
    
    func test_todayAction() {
        // Given
        let reactor = ExpenseViewReactor(dateRepository: dateRepository)
        let today = Date()
        
        // When
        reactor.action.onNext(.todayButtonTapped)
            
        // Then
        XCTAssertEqual(DateFormatter.year(from: reactor.currentState.dateToShow), DateFormatter.year(from: today))
        XCTAssertEqual(DateFormatter.month(from: reactor.currentState.dateToShow), DateFormatter.month(from: today))
    }
    
    /// showModeButtonTapped Action Test
    func test_changeShowModeAction() {
        // Given
        let reactor = ExpenseViewReactor(dateRepository: dateRepository)
        
        // When
        reactor.action.onNext(.showModeButtonTapped)
        reactor.action.onNext(.showModeButtonTapped)
        reactor.action.onNext(.showModeButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.showMode, .calendar)
    }
}
