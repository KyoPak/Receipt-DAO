//
//  StorageServiceError.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import Foundation

enum StorageServiceError: Error {
    case entityUpdateError
    case entityDeleteError
}

extension StorageServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .entityUpdateError:
            return ConstantText.entityUpdateError.localize()

        case .entityDeleteError:
            return ConstantText.entityDeleteError.localize()
        }
    }
}
