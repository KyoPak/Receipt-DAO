//
//  AnalysisViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/14/23.
//

import XCTest
import RxSwift
import RxTest
@testable import ReceiptManager

final class AnalysisViewReactorTests: XCTestCase {
    private let disposeBag = DisposeBag()
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
    
    func test_nextMonthButtonTappedAction() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        let nextMonth = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date()
        
        // When
        reactor.action.onNext(.nextMonthButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.dateToShow.description, nextMonth.description)
    }
    
    func test_previoutMonthButtonTapped() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        let previousMonth = Calendar.current.date(byAdding: DateComponents(month: -1), to: Date()) ?? Date()
        
        // When
        reactor.action.onNext(.previoutMonthButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.dateToShow.description, previousMonth.description)
    }
    
    func test_todayButtonTapped() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        let today = Date()
        
        // When
        reactor.action.onNext(.todayButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.dateToShow.description, today.description)
    }
    
    func test_userDefaultEvent() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int.self)
        
        // When
        reactor.state.map { $0.currency }
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) {
            self.mockUserDefaultService.updateCurrency(index: 1)
        }
        
        scheduler.start()
        
        // Then
        XCTAssertEqual(observer.events.compactMap { $0.value.element }, [0, 1])
    }
    
    func test_Analysis_CountLogic() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        /// Origin Storage have 3 cash Data.
        let mockData1 = Receipt(priceText: "10000", paymentType: 1)
        let mockData2 = Receipt(priceText: "10000", paymentType: 1)
        let mockData3 = Receipt(priceText: "10000", paymentType: 1)
        
        mockStorageService.upsert(receipt: mockData1)
        mockStorageService.upsert(receipt: mockData2)
        mockStorageService.upsert(receipt: mockData3)
        
        // When
        reactor.action.onNext(.todayButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.totalCount, 6)
        XCTAssertEqual(reactor.currentState.cardCount, 3)
        XCTAssertEqual(reactor.currentState.cashCount, 3)
    }
    
    func test_Analysis_RatingLogic() {
        // Given
        let reactor = AnalysisViewReactor(storageService: mockStorageService, userDefaultService: mockUserDefaultService, dateService: mockDateService)
        let nextMonth = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date()
        
        let mockData1 = Receipt(priceText: "10000")
        let mockData2 = Receipt(priceText: "10000")
        let mockData3 = Receipt(priceText: "20000", receiptDate: nextMonth)
        let mockData4 = Receipt(priceText: "20000", receiptDate: nextMonth)
        
        mockStorageService.upsert(receipt: mockData1)
        mockStorageService.upsert(receipt: mockData2)
        mockStorageService.upsert(receipt: mockData3)
        mockStorageService.upsert(receipt: mockData4)
        
        // When
        reactor.action.onNext(.nextMonthButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.rate.rateText, ConstantText.ratingUp.localized(with: "100%"))
    }
}
