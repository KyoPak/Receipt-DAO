//
//  OCRRepositoryTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import XCTest
import RxSwift
@testable import ReceiptManager

final class OCRRepositoryTests: XCTestCase {
    private var service: MockOCRExtractorService!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        service = MockOCRExtractorService()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        service = nil
        disposeBag = nil
    }
    
    func test_extract() {
        // Given
        let targetText = ["Test Text"]
        let repository = DefaultOCRRepository(service: service)
        
        // When
        let result = repository.extractText(by: Data())
        
        // Then
        result.subscribe { text in
            XCTAssertEqual(targetText, text)
        } onError: { error in
            XCTFail()
        }
        .disposed(by: disposeBag)
    }
    
    func test_extract_when_error() {
        // Given
        let targetText = ["Test Text"]
        let repository = DefaultOCRRepository(service: service)
        service.error = .extractFail
        
        // When
        let result = repository.extractText(by: Data())
        
        // Then
        result.subscribe { text in
            XCTFail("Expect Error")
        } onError: { error in
            XCTAssert(true)
        }
        .disposed(by: disposeBag)
    }
}
