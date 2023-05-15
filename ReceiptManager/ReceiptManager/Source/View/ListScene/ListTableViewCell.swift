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
        imageView.tintColor = ConstantColor.favoriteColor
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "wonsign.square.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var mainInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productNameLabel, storeLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let storeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private lazy var subInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceLabel, detailButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        
        return button
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
        payImageView.tintColor = ConstantColor.favoriteColor
    }
    
    func setupData(data: Receipt) {
        productNameLabel.text = data.product
        storeLabel.text = data.store
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        priceLabel.text = String(numberFormatter.string(from: NSNumber(value: data.price)) ?? "0") + " 원"
        
        if PayType(rawValue: data.paymentType) == .card {
            payImageView.tintColor = ConstantColor.registerColor
            payImageView.image = UIImage(systemName: "creditcard.fill")
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
        
        [payImageView, mainInfoStackView, subInfoStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
