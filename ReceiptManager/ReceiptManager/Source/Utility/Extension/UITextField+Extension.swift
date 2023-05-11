//
//  UITextField+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

extension UITextField {
    func setPlaceholder(color: UIColor) {
        guard let string = self.placeholder else {
            return
        }
        attributedPlaceholder = NSAttributedString(string: string, attributes: [.foregroundColor: color])
    }
}
