//
//  MonthControlView.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/7/23.
//

import UIKit

final class MonthControlView: UIView {
    
    // UI Properties
    
    let monthLabel = UILabel(font: .systemFont(ofSize: 15, weight: .bold))
    
    let previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronLeft), for: .normal)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronRight), for: .normal)
        return button
    }()
    
    let currentButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.today.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = ConstantColor.cellColor
        button.layer.cornerRadius = 5
        return button
    }()
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Constraints
extension MonthControlView {
    private func setupHierarchy() {
        [monthLabel, previousButton, nextButton, currentButton].forEach(addSubview(_:))
        backgroundColor = ConstantColor.backGroundColor
    }
    
    private func setupProperties() {
        [monthLabel, previousButton, nextButton, currentButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 40),
            previousButton.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -5),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 45),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 5),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            currentButton.widthAnchor.constraint(equalToConstant: 60),
            currentButton.heightAnchor.constraint(equalToConstant: 30),
            currentButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            currentButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
