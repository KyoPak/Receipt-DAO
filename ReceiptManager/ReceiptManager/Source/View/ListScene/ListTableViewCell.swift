//
//  ListTableViewCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/08.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    let receiptImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "DefaultReceipt")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let productLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    lazy var subStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [paymentTypeLabel, dateLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        return stackView
    }()
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productLabel, subStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        return stackView
    }()
    
    lazy var totalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainStackView, priceLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(data: Receipt) {
        if let imageData = data.receiptData {
            receiptImageView.image = UIImage(data: imageData)
        }
        
        productLabel.text = data.product
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        priceLabel.text = numberFormatter.string(from: NSNumber(value: data.price))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateLabel.text = dateFormatter.string(from: data.receiptDate)
        
        paymentTypeLabel.text = PayType(rawValue: data.paymentType)?.description
    }
}

// MARK: - UIConstaints
extension ListTableViewCell {
    private func setupView() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.listColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        
        [receiptImageView, totalStackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [receiptImageView, totalStackView].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        
    }
}

extension ListTableViewCell: CellReuseIdentifiable { }
