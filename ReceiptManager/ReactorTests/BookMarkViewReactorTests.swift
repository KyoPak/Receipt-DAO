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
        let mockExpense1 = Receipt.mockExpense()
        let mockExpense2 = Receipt.mockExpense()
        mockStorageService.upsert(receipt: mockExpense1)
        mockStorageService.upsert(receipt: mockExpense2)
        
        let reactor = BookMarkViewReactor(
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService
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
        mockStorageService.upsert(receipt: mockExpense1)
        mockStorageService.upsert(receipt: mockExpense2)
        
        let reactor = BookMarkViewReactor(
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService
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
