//
//  UIStackView+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/16.
//

import UIKit

extension UIStackView {
    convenience init(
        subViews: [UIView],
        axis: NSLayoutConstraint.Axis,
        alignment: Alignment,
        distribution: Distribution,
        spacing: CGFloat
    ) {
        self.init(arrangedSubviews: subViews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
