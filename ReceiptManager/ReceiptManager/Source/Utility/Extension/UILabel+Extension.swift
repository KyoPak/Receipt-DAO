//
//  UILabel+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

extension UILabel {
    convenience init(text: String = "", font: UIFont) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = .label
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UILabel {
    func setMutableFontColor(target: String, font: UIFont?, color: UIColor?) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: target)
        attributedString.addAttributes([.font: font as Any, .foregroundColor: color as Any], range: range)
        attributedText = attributedString
    }
}
