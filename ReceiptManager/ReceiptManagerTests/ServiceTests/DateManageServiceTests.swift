//
//  DateManageServiceTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import XCTest
import RxSwift

@testable import ReceiptManager

final class DateManageServiceTests: XCTestCase {
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
    }
    
    func test_update() {
        // Given
        let targetDate = Date()
        let service = DefaultDateManageService()
        let calendar = Calendar.current
        let updatedDate = calendar.date(byAdding: DateComponents(month: 1), to: targetDate) ?? Date()

        // When
        let result = service.update(byAddingMonths: 1)
            
        // Then
        result.subscribe { date in
            XCTAssertEqual(updatedDate, date)
        }
        .disposed(by: disposeBag)
    }

    func test_reset() {
        // Given
        let service = DefaultDateManageService()
        
        // When
        let _ = service.update(byAddingMonths: 1)
        let result = service.reset()
        
        // Then
        result.subscribe { date in
            XCTAssertNotEqual(Date(), date)
        }
        .disposed(by: disposeBag)
    }
}
