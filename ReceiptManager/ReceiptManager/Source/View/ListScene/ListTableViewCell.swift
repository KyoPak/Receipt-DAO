//
//  ListTableViewCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/08.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    private let paymentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .yellow
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(systemName: "wonsign.square.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let storeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            paymentImageView,
            productNameLabel,
            storeLabel,
            priceLabel
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        
        return stackView
    }()
    
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
        paymentImageView.tintColor = .yellow
    }
    
    func setupData(data: Receipt) {
        productNameLabel.text = data.product
        storeLabel.text = data.store
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        priceLabel.text = numberFormatter.string(from: NSNumber(value: data.price))
        
        if PayType(rawValue: data.paymentType) == .card {
            paymentImageView.tintColor = .blue
            paymentImageView.image = UIImage(systemName: "creditcard.fill")
        }
    }
}

// MARK: - UIConstaints
extension ListTableViewCell {
    private func setupView() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.listColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        
        [mainStackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [mainStackView].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

extension ListTableViewCell: CellReuseIdentifiable { }
