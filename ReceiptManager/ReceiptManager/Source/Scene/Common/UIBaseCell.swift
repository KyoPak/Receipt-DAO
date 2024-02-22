//
//  BaseCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/22/24.
//

import UIKit

class UIBaseTableViewCell: UITableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        layer.borderColor = ConstantColor.layerColor.cgColor
    }
}

class UIBaseCollectionViewCell: UICollectionViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        layer.borderColor = ConstantColor.cellColor.cgColor
    }
}
