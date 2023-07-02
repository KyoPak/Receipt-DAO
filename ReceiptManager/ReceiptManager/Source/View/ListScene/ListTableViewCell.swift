//
//  ListTableViewCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/08.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    private let payImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let productNameLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    private let storeLabel = UILabel(font: .systemFont(ofSize: 20, weight: .semibold))
    private let priceLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: ConstantImage.chevronRight), for: .normal)
        
        return button
    }()
    
    private lazy var mainInfoStackView = UIStackView(
        subViews: [storeLabel, productNameLabel],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 7
    )

    private lazy var subInfoStackView = UIStackView(
        subViews: [priceLabel, detailButton],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
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
        payImageView.tintColor = nil
        detailButton.tintColor = nil
    }
    
    func setupData(data: Receipt, currency: String) {
        productNameLabel.text = data.product
        storeLabel.text = data.store
        
        if data.isFavorite {
            detailButton.tintColor = .systemYellow
            detailButton.setImage(UIImage(systemName: ConstantImage.bookMarkFill), for: .normal)
        } else {
            detailButton.tintColor = .lightGray
            detailButton.setImage(UIImage(systemName: ConstantImage.chevronRight), for: .normal)
        }
        
        priceLabel.text = NumberFormatter.numberDecimal(from: data.price) + currency
        
        if PayType(rawValue: data.paymentType) == .card {
            payImageView.tintColor = ConstantColor.registerColor
            payImageView.image = UIImage(systemName: ConstantImage.creditCard)
        } else {
            payImageView.tintColor = ConstantColor.favoriteColor
            payImageView.image = UIImage(systemName: ConstantImage.wonSign)
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
        
        [payImageView, mainInfoStackView, subInfoStackView].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            payImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            payImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            payImageView.widthAnchor.constraint(equalToConstant: 50),
            payImageView.heightAnchor.constraint(equalToConstant: 50),
            
            mainInfoStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            mainInfoStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            mainInfoStackView.leadingAnchor.constraint(equalTo: payImageView.trailingAnchor, constant: 10),
            mainInfoStackView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.5),
            
            subInfoStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            subInfoStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}

extension ListTableViewCell: CellReuseIdentifiable { }
