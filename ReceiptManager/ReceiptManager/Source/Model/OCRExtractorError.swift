//
//  OCRExtractorError.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/20/23.
//

import Foundation

enum OCRExtractorError: Error {
    case extractError
}

extension OCRExtractorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .extractError:
            return ConstantText.extractError.localize()
        }
    }
}
