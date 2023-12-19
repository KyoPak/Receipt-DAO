//
//  StorageServiceError.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import Foundation

enum StorageServiceError: Error {
    case defaultError
    case entityInsertError
    case entityUpdateError
    case entityDeleteError
}

extension StorageServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .defaultError:
            return nil
        
        // TODO: - Localizing
        case .entityInsertError:
            return "등록에 실패하였습니다.\n용량을 확인해주세요."
        
        case .entityUpdateError:
            return "업데이트에 실패하였습니다.\n용량을 확인해주세요."

        case .entityDeleteError:
            return "삭제가 실패하였습니다."
        }
    }
}
