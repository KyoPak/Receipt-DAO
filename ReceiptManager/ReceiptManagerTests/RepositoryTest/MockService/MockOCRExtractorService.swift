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
    var error: MockOCRExtractorError?
    
    func extract(data: Data) -> Observable<[String]> {
        if error != nil { return Observable.error(error ?? .extractFail) }
        
        ocrResult.onNext(["Test Text"])
        return ocrResult
    }
}

enum MockOCRExtractorError: Error {
    case extractFail
}
