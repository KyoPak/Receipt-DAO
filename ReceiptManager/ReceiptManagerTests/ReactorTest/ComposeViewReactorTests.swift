//
//  ComposeViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/14/23.
//

import XCTest
import RxSwift
import RxTest
@testable import ReceiptManager

final class ComposeViewReactorTests: XCTestCase {
    private let disposeBag = DisposeBag()
    private var mockExpenseRepository: ExpenseRepository!
    private var mockOCRRepository: OCRRepository!
    
    override func setUpWithError() throws {
        mockExpenseRepository = MockExpenseRepository()
        mockOCRRepository = MockOCRRepository()
    }
    
    override func tearDownWithError() throws {
        mockExpenseRepository = nil
        mockOCRRepository = nil
    }
    
    func test_priceTextChanged() {
        // Given
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let targetText = "123456789"
        
        // When
        reactor.action.onNext(.priceTextChanged(targetText))
        
        // Then
        XCTAssertEqual(reactor.currentState.priceText, "123,456,789")
    }
    
    func test_imageAppendAction() {
        // Given
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let mockData = Data()
        
        // When
        reactor.action.onNext(.imageAppend(mockData))
        reactor.action.onNext(.imageAppend(mockData))
        
        // Then
        XCTAssertEqual(reactor.currentState.registerdImageDatas.count - 1, 2)
    }
    
    func test_cellDeleteButtonTappedAction() {
        // Given
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let mockData = Data()
        reactor.action.onNext(.imageAppend(mockData))
        reactor.action.onNext(.imageAppend(mockData))
        
        // When
        reactor.action.onNext(.cellDeleteButtonTapped(IndexPath(item: 1, section: .zero)))
        
        // Then
        XCTAssertEqual(reactor.currentState.registerdImageDatas.count, 2)
    }
    
    func test_registerButtonTappedAction() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let mockSaveData = ComposeViewReactor.SaveExpense(date: Date(), paymentType: .zero)
        
        // When
        scheduler
            .createHotObservable([
                .next(100, .registerButtonTapped(mockSaveData))
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.successExpenseRegister }
        }
        
        // Then
        XCTAssertEqual(response.events.compactMap { $0.value.element }.count, 3)
    }
    
    func test_imageAppendButtonTappedAction_when_imageCountIs5() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let mockData = Data()
        
        for _ in 0..<5 {
            reactor.action.onNext(.imageAppend(mockData))
        }
        
        // When
        scheduler
            .createHotObservable([
                .next(100, .imageAppendButtonTapped(IndexPath(item: .zero, section: .zero)))
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.imageAppendEnable }
        }
        
        // Then
        XCTAssertEqual(response.events.compactMap { $0.value.element }, [nil, false, nil])
    }
    
    func test_imageAppendButtonTappedAction_when_imageCountIsZero() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        
        // When
        scheduler
            .createHotObservable([
                .next(100, .imageAppendButtonTapped(IndexPath(item: .zero, section: .zero)))
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.imageAppendEnable }
        }
        
        // Then
        XCTAssertEqual(response.events.compactMap { $0.value.element }, [nil, true, nil])
    }
    
    func test_cellOCRButtonAction_OCRExtractorEvent() {
        // Given
        let scheduler = TestScheduler(initialClock: .zero)
        let reactor = ComposeViewReactor(
            expenseRepository: mockExpenseRepository,
            ocrRepository: mockOCRRepository,
            transisionType: .modal
        )
        let mockData = Data()
        reactor.action.onNext(.imageAppend(mockData))
        
        // When
        scheduler
            .createHotObservable([
                .next(100, .cellOCRButtonTapped(IndexPath(item: 1, section: .zero)))
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)

        
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.ocrResult }
        }
        
        // Then
        XCTAssertEqual(response.events.compactMap { $0.value.element }, [nil, ["Test Text"], nil])
    }
}
