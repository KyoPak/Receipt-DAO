//
//  CalendarCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import UIKit

final class CalendarCell: UICollectionViewCell {
    
    // UI Properties
    
    private let dayLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 12))
    private let countLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 10))
    
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
    
    func setupData(day: String, count: Int) {
        dayLabel.text = day
        countLabel.text = String(count)
    }
}

// MARK: - UI Constraints
extension CalendarCell {
    private func setupHierarchy() {
        [dayLabel, countLabel].forEach(addSubview(_:))
    }
    
    private func setupProperties() {
        [dayLabel, countLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension CalendarCell: CellReuseIdentifiable { }
