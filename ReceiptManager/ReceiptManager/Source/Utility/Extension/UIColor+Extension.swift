//
//  UIColor+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/11/23.
//

import UIKit

extension UIColor {
    func image(withSize size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
