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
        let reactor = SearchViewReactor(
            storageService: mockStorageService,
            userDefaultService: mockUserDefaultService
        )
        let targetText = "Test"
        mockStorageService.upsert(receipt: Receipt(store: targetText))
        mockStorageService.upsert(receipt: Receipt(product: targetText))
        mockStorageService.upsert(receipt: Receipt(memo: targetText))
        
        // When
        reactor.action.onNext(.searchExpense(targetText))
        
        // Then
        XCTAssertEqual(reactor.currentState.searchText, targetText)
        XCTAssertEqual(reactor.currentState.searchResult.first?.items.count, 3)
    }
}
