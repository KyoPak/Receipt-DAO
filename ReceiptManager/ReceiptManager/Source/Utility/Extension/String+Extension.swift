//
//  String+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/29.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with argument: CVarArg) -> String {
        return String(format: self.localize(), argument)
    }
}
