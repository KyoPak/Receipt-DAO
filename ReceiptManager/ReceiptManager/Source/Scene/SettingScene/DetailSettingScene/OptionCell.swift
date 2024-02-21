//
//  OptionCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import UIKit

import RxSwift
import RxCocoa

final class OptionCell: UITableViewCell {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let optionLabel = UILabel(font: .systemFont(ofSize: 15, weight: .medium))

    private let selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    // Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectImageView.image = nil
    }
    
    
    func setupData(optionText: String) {
        optionLabel.text = optionText
    }
}

// MARK: - UIConstaints
extension OptionCell {
    private func setupView() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.layerColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        
        [optionLabel, selectImageView].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

            optionLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            optionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            selectImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            selectImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}

extension OptionCell: CellReuseIdentifiable { }
