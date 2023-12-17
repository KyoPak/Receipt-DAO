//
//  OCRExtractorService.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import Foundation
import Vision
import VisionKit

import RxSwift

protocol OCRExtractorService {
    var ocrResult: PublishSubject<[String]> { get set }
    func extractText(data: Data)
}

final class DefaultOCRExtractorService: OCRExtractorService {
    var ocrResult = PublishSubject<[String]>()
    private let currency: Currency
    
    init(currencyIndex: Int?) {
        currency = Currency(rawValue: currencyIndex ?? .zero) ?? .KRW
    }
    
    func extractText(data: Data) {
        guard let image = UIImage(data: data)?.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let ocrText = observations.compactMap { text in
                text.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            ocrResult.onNext(ocrText)
        }
        
        request.recognitionLanguages =  recognitionLanguages()
        request.revision = revision()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    private func recognitionLanguages() -> [String] {
        switch currency {
        case .KRW:
            if #available(iOS 16.0, *) {
                return ["ko-KR"]
            }
            return ["en-US"]
        case .USD:
            return ["en-US"]
        case .JPY:
            return ["ja-JP"]
        }
    }
    
    private func revision() -> Int {
        if #available(iOS 16.0, *) {
            return VNRecognizeTextRequestRevision3
        } else {
            return VNRecognizeTextRequestRevision2
        }
    }
}
