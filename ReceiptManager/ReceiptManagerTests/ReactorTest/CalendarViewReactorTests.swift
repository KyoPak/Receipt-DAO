//
//  CalendarViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class CalendarViewReactorTests: XCTestCase {
    private var mockStorageService: StorageService!
    private var mockUserDefaultService: UserDefaultService!
    private var mockDateService: DateManageService!
    
    override func setUpWithError() throws {
        mockStorageService = MockStoragService()
        mockUserDefaultService = MockUserDefaultService()
        mockDateService = DefaultDateManageService()
    }

    override func tearDownWithError() throws {
        mockStorageService = nil
        mockUserDefaultService = nil
        mockDateService = nil
    }
    
    func test_loadDataAction() {
        // Given
        let reactor = CalendarViewReactor(
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
            dateManageService: mockDateService
        )
        let date = Date()
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month], from: date)
        let convertDate = calendar.date(from: component) ?? Date()
        let total = calendar.component(.weekday, from: convertDate) - 1 +
                    (calendar.range(of: .day, in: .month, for: convertDate)?.count ?? .zero)
        
        // When
        reactor.action.onNext(.loadData)
        
        // Then
        XCTAssertEqual(reactor.currentState.dayInfos.count, total)
        XCTAssertEqual(reactor.currentState.expenseByMonth.first?.items.count, 3)
    }
    
    func test_dateEventChange() {
        // Given
        let reactor = CalendarViewReactor(
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
            dateManageService: mockDateService
        )
        reactor.action.onNext(.loadData)
        let nextDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date()
        mockStorageService.upsert(receipt: Receipt(receiptDate: nextDate))
        
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month], from: nextDate)
        let convertDate = calendar.date(from: component) ?? Date()
        let total = calendar.component(.weekday, from: convertDate) - 1 +
                    (calendar.range(of: .day, in: .month, for: convertDate)?.count ?? .zero)
        
        // When
        mockDateService.updateDate(byAddingMonths: 1)
        reactor.action.onNext(.loadData)
        
        // Then
        XCTAssertEqual(reactor.currentState.dayInfos.count, total)
        XCTAssertEqual(reactor.currentState.expenseByMonth.first?.items.count, 1)
    }
}
