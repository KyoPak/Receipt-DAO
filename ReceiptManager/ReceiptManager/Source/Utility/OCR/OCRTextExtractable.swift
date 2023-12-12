//
//  OCRTextExtractable.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import Foundation
import Vision
import VisionKit

import RxSwift

protocol OCRTextExtractable {
    var ocrResult: PublishSubject<[String]> { get set }
    func extractText(data: Data)
}

final class OCRTextExtractor: OCRTextExtractable {
    var ocrResult = PublishSubject<[String]>()
    
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
        
        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLanguages =  ["ko-KR"]
        } else {
            request.revision = VNRecognizeTextRequestRevision2
            request.recognitionLanguages =  ["en-US"]
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
