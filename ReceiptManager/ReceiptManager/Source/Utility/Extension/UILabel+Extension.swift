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
        self.textColor = .white
        translatesAutoresizingMaskIntoConstraints = false
    }
}
