//
//  UITextField+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

extension UITextField {
    convenience init(textColor: UIColor, placeholder: String, tintColor: UIColor, backgroundColor: UIColor) {
        self.init()
        self.textColor = textColor
        self.tintColor = tintColor
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UITextField {
    func setPlaceholder(color: UIColor) {
        guard let string = self.placeholder else {
            return
        }
        attributedPlaceholder = NSAttributedString(string: string, attributes: [.foregroundColor: color])
    }
}
