//
//  ListTableViewCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/08.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class ListTableViewCell: UITableViewCell, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let payImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let storeLabel = UILabel(font: .systemFont(ofSize: 15, weight: .medium))
    private let priceLabel = UILabel(font: .systemFont(ofSize: 15, weight: .semibold))
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: ConstantImage.chevronRight), for: .normal)
        
        return button
    }()

    private lazy var subInfoStackView = UIStackView(
        subViews: [priceLabel, detailButton],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
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
        payImageView.tintColor = nil
        detailButton.tintColor = nil
    }
    
    func bind(reactor: ListTableViewCellReactor) {
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension ListTableViewCell {
    private func bindState(_ reactor: ListTableViewCellReactor) {
        reactor.state
            .withUnretained(self)
            .bind { (owner, state) in
                owner.setupData(data: state.expense, currencyIndex: state.currency)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupData(data: Receipt, currencyIndex: Int) {
        guard let currency = Currency(rawValue: currencyIndex) else { return }
        priceLabel.text = NumberFormatter.numberDecimal(from: data.priceText) + currency.description
        storeLabel.text = data.store
        
        let detailButtonImage = data.isFavorite ? ConstantImage.bookMarkFill : ConstantImage.chevronRight
        detailButton.setImage(UIImage(systemName: detailButtonImage), for: .normal)
        detailButton.tintColor = data.isFavorite ? .systemYellow : .lightGray
        
        let payTypeResult = PayType(rawValue: data.paymentType) == .card
        let paymentImageName = payTypeResult ? ConstantImage.creditCard : currency.currencyImageText
        payImageView.tintColor = payTypeResult ? ConstantColor.subColor : ConstantColor.mainColor
        payImageView.image = UIImage(systemName: paymentImageName)
    }
}

// MARK: - UIConstaints
extension ListTableViewCell {
    private func setupView() {
        backgroundColor = ConstantColor.cellColor
        layer.borderColor = ConstantColor.layerColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        
        [payImageView, storeLabel, subInfoStackView].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            payImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            payImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            payImageView.widthAnchor.constraint(equalToConstant: 30),
            payImageView.heightAnchor.constraint(equalToConstant: 30),
            
            storeLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            storeLabel.leadingAnchor.constraint(equalTo: payImageView.trailingAnchor, constant: 10),
            storeLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.5),
            
            subInfoStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            subInfoStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}

extension ListTableViewCell: CellReuseIdentifiable { }
