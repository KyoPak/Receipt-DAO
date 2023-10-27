//
//  SettingCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

final class SettingCell: UITableViewCell {
    private let optionLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    weak var delegate: SegmentDelegate?
    
    let currencySegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: [ConstantText.krw, ConstantText.usd, ConstantText.jpy])
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        segment.isHidden = true
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        return segment
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SegmentController Action
extension SettingCell {
    @objc private func changedCurrency() {
        delegate?.changedValue(index: currencySegmented.selectedSegmentIndex)
    }
}

// MARK: - UI Constraint & Setting UI Component
extension SettingCell {
    private func setupView() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.cellColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        [optionLabel, currencySegmented].forEach(contentView.addSubview(_:))
        
        currencySegmented.addTarget(self, action: #selector(changedCurrency), for: .valueChanged)
    }
    
    func setupData(text: String) {
        optionLabel.text = text
    }
    
    func showSegment(index: Int) {
        currencySegmented.isHidden = false
        currencySegmented.selectedSegmentIndex = index
        setupSegmentConstraint()
    }
    
    private func setupSegmentConstraint() {
        let safeArea = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            currencySegmented.topAnchor.constraint(equalTo: optionLabel.topAnchor),
            currencySegmented.leadingAnchor.constraint(equalTo: optionLabel.trailingAnchor, constant: 10),
            currencySegmented.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            currencySegmented.bottomAnchor.constraint(equalTo: optionLabel.bottomAnchor)
        ])
        optionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        currencySegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func setupConstraint() {
        let safeArea = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            optionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            optionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            optionLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10)
        ])
    }
}

extension SettingCell: CellReuseIdentifiable { }
