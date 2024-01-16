//
//  OCRRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol OCRRepository {
    func extractText(by data: Data) -> Observable<[String]>
}

final class DefaultOCRRepository: OCRRepository {
    private let service: OCRExtractorService
    
    init(service: OCRExtractorService) {
        self.service = service
    }
    
    func extractText(by data: Data) -> Observable<[String]> {
        return service.extract(data: data)
    }
}
