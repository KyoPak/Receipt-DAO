//
//  BasePaddingLabel.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/28/23.
//

import UIKit

final class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
