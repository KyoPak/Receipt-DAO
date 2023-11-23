//
//  SettingCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

import RxSwift

@objc protocol SegmentDelegate: AnyObject {
    @objc dynamic func segmentDelegate(index: Int)
}

final class SettingCell: UITableViewCell {
    
    // Properties
    
    weak var delegate: SegmentDelegate?
    private var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let optionLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    
    private let currencySegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: [ConstantText.krw, ConstantText.usd, ConstantText.jpy])
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        segment.isHidden = true
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        return segment
    }()
    
    // Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currencySegmented.isHidden = true
    }
    
    private func bind() {
        currencySegmented.rx.selectedSegmentIndex
            .asDriver(onErrorJustReturn: .zero)
            .drive { self.delegate?.segmentDelegate(index: $0) }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Constraint & Setting UI Component
extension SettingCell {
    private func setupHierarchy() {
        [optionLabel, currencySegmented].forEach(contentView.addSubview(_:))
    }
    
    private func setupProperties() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.layerColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    func setupData(text: String) {
        optionLabel.text = text
    }
    
    func setupSegment(index: Int) {
        currencySegmented.isHidden = false
        currencySegmented.selectedSegmentIndex = index
        bind()
        setupSegmentConstraints()
    }
    
    private func setupSegmentConstraints() {
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
    
    private func setupConstraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            optionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            optionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            optionLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10)
        ])
    }
}

extension SettingCell: CellReuseIdentifiable { }
