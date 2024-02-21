//
//  CurrencyRepositoryTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class CurrencyRepositoryTests: XCTestCase {
    private var service: UserDefaultService!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        service = MockUserDefaultService()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        service = nil
        disposeBag = nil
    }
    
    func test_fetchCurrencyIndex() {
        // Given
        let repository = DefaultUserSettingRepository(service: service)
        
        // When
        let result = repository.fetchCurrencyIndex()
        
        // Then
        XCTAssertEqual(.zero, result)
    }
    
    func test_updateCurrencyIndex() {
        // Given
        let repository = DefaultUserSettingRepository(service: service)
        
        // When
        let result = repository.updateCurrency(index: 1)
        let target = repository.fetchCurrencyIndex()
        // Then
        result.subscribe { index in
            XCTAssertEqual(target, index)
        }
        .disposed(by: disposeBag)
    }
}
