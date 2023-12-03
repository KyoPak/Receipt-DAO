//
//  CalendarCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import UIKit

final class CalendarCell: UICollectionViewCell {
    
    // UI Properties
    
    private let dayLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 13))
    private let countLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 12))
    private let amountLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 12))
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupData(day: String, count: String, amount: String) {
        dayLabel.text = day
        countLabel.text = count
        
        if amount == "0" {
            amountLabel.text = ""
        } else {
            amountLabel.text = amount
        }
    }
}

// MARK: - UI Constraints
extension CalendarCell {
    private func setupHierarchy() {
        [dayLabel, countLabel, amountLabel].forEach(addSubview(_:))
    }
    
    private func setupProperties() {
        layer.borderColor = ConstantColor.cellColor.cgColor
        layer.borderWidth = 1
        amountLabel.textColor = ConstantColor.favoriteColor
        [dayLabel, countLabel, amountLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    private func setupContraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 3),
            
            countLabel.topAnchor.constraint(equalTo: safeArea.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3),
            amountLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -5),
            amountLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3)
        ])
    }
}

extension CalendarCell: CellReuseIdentifiable { }
