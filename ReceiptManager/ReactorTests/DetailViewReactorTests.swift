//
//  DetailViewReactorTests.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class DetailViewReactorTests: XCTestCase {
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
    
    func test_viewWillAppearAction() {
        // Given
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
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
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
            item: mockExpense
        )
        
        // When
        reactor.action.onNext(.shareButtonTapped)
        
        // Then
        XCTAssertEqual(reactor.currentState.shareExpense, nil)
    }
    
    func test_editAction() {
        // Given
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
            item: mockExpense
        )
        
        // When
        reactor.action.onNext(.edit)
        
        // Then
        XCTAssertEqual(reactor.currentState.editExpense, nil)
    }
    
    func test_deleteAction() {
        // Given
        let mockExpense = Receipt.mockExpense()
        let reactor = DetailViewReactor(
            title: "",
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService,
            item: mockExpense
        )
        
        // When
        reactor.action.onNext(.delete)
        
        // Then
        XCTAssertFalse(reactor.currentState.deleteExpense == nil)
    }
}

private extension Receipt {
    static func mockExpense() -> Receipt {
        return Receipt(store: "테스트", priceText: "100000", product: "테스트Product")
    }
}
