//
//  OCRTextExtractable.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import Foundation
import Vision
import VisionKit

protocol OCRTextExtractable {
    func extractText(data: Data, completion: @escaping (OCRResult) -> Void)
}

final class OCRTextExtractor: OCRTextExtractable {
    func extractText(data: Data, completion: @escaping (OCRResult) -> Void) {
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
            
            let filterResult = self.filterOCR(ocrText)
            
            DispatchQueue.main.async {
                completion(filterResult)
            }
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
    
    private func filterOCR(_ result: [String]) -> OCRResult {
        var ocrResult = OCRResult()
        
        // 상호명 Default
        ocrResult.store = result[0]
        
        for index in 0..<result.count {
            let text = result[index]
            
            // 상호명 추출
            if text == "상호명" && index + 1 < result.count {
                ocrResult.store = result[index + 1]
                continue
            }
            
            if let dateExtract = extractDate(from: text) {
                ocrResult.date = dateExtract
            }
            
            if let priceExtract = extractPrice(from: text) {
                ocrResult.price = priceExtract
            }
            
            if let payTypeExtract = extractPayType(from: text) {
                ocrResult.paymentType = payTypeExtract
            }
        }
        
        return ocrResult
    }
    
    // 날짜 추출
    private func extractDate(from text: String) -> Date? {
        let dateFormats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy/MM/dd HH:mm:ss",
            "yy-MM-dd HH:mm:ss",
            "yy/MM/dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 날짜 형식의 로케일 설정
        
        for format in dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: text) {
                return date
            }
        }
        
        return nil
    }
    
    // 가격 추출
    private func extractPrice(from text: String) -> Int? {
        if text.contains("원") || text.contains(".") || text.contains(",") {
            let priceText = text.replacingOccurrences(of: "원", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: " ", with: "")
            
            guard let price = Int(priceText) else { return nil }
            return price
        }
        
        return nil
    }
    
    private func extractPayType(from text: String) -> Int? {
        if text.contains(PayType.cash.description) {
            return PayType.cash.rawValue
        } else if text.contains(PayType.card.description) {
            return PayType.card.rawValue
        }
        
        return nil
    }
}
