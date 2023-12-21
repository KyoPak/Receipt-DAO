//
//  Double+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/8/23.
//

import Foundation

extension Double {    
    func convertString() -> String {
        return self == .zero ? "" : self.isConvertableInt() ? String(Int(self)) : String(self)
    }
    
    private func isConvertableInt() -> Bool {
        return Double(Int(self)) == self
    }
}
