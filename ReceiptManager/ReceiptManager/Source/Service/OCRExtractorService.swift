//
//  OCRExtractorService.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import Foundation
import Vision
import VisionKit

import FirebaseCrashlytics
import RxSwift

protocol OCRExtractorService {
    func extract(data: Data) -> Observable<[String]>
}

final class DefaultOCRExtractorService: OCRExtractorService {
    private let currency: Currency
    
    init(currencyIndex: Int?) {
        currency = Currency(rawValue: currencyIndex ?? .zero) ?? .KRW
    }
    
    func extract(data: Data) -> Observable<[String]> {
        return Observable.create { [weak self] observer in
            guard let self = self, let image = UIImage(data: data)?.cgImage else {
                observer.onError(OCRExtractorError.extractError)
                return Disposables.create()
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil
                else {
                    observer.onError(OCRExtractorError.extractError)
                    return
                }
                
                let ocrText = observations.compactMap { text in
                    text.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                observer.onNext(ocrText)
                observer.onCompleted()
            }
            
            request.recognitionLanguages = self.recognitionLanguages()
            request.revision = self.revision()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try handler.perform([request])
            } catch {
                Crashlytics.crashlytics().record(error: error)
                observer.onError(OCRExtractorError.extractError)
            }
            
            return Disposables.create()
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
