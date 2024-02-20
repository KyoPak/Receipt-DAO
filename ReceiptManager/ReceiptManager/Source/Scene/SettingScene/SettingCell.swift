//
//  SettingCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

import RxSwift

final class SettingCell: UITableViewCell {
    
    // Properties
    
    private var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let optionLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    private let optionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: ConstantImage.chevronRight), for: .normal)
        
        return button
    }()
    
    // Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupProperties()
        setupConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {

    }
}

// MARK: - UI Constraint & Setting UI Component
extension SettingCell {
    private func setupHierarchy() {
        [optionLabel, optionButton].forEach(contentView.addSubview(_:))
    }
    
    private func setupProperties() {
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.tintColor = .lightGray
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.layerColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    func setupData(text: String) {
        optionLabel.text = text
    }
    
    private func setupConstraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            optionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            optionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            optionLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            
            optionButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            optionButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10)
        ])
    }
}

extension SettingCell: CellReuseIdentifiable { }
