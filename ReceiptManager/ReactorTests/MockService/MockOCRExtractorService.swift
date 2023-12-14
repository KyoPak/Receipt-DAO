//
//  MockOCRExtractorService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/14/23.
//

import RxSwift
@testable import ReceiptManager

final class MockOCRExtractorService: OCRExtractorService {
    var ocrResult = PublishSubject<[String]>()
    
    func extractText(data: Data) {
        ocrResult.onNext(["Test Text"])
    }
}
