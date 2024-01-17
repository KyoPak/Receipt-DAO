//
//  MockOCRRepository.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import RxSwift
@testable import ReceiptManager

final class MockOCRRepository: OCRRepository {
    private let mockData = ["Test Text"]
    func extractText(by data: Data) -> Observable<[String]> {
        return Observable.just(mockData)
    }
}
