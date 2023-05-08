//
//  UIButton+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

extension UIButton {
    func alignTextBelow(spacing: CGFloat = 4.0) {
        guard let image = self.imageView?.image else { return }
        
        guard let titleLabel = self.titleLabel else { return }
        
        guard let titleText = titleLabel.text else { return }
        
        let titleSize = titleText.size(withAttributes: [
            NSAttributedString.Key.font: titleLabel.font as Any
        ])
        
        titleEdgeInsets = UIEdgeInsets(
            top: spacing,
            left: -image.size.width,
            bottom: -image.size.height,
            right: .zero
        )
        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: .zero,
            bottom: .zero,
            right: -titleSize.width
        )
    }
}
