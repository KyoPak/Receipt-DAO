//
//  ComposeInformationView.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import UIKit

final class ComposeInformationView: UIView {
    let datePicker = UIDatePicker()
    private let dateLabel = UILabel(
        text: ConstantText.date.localize(),
        font: .preferredFont(forTextStyle: .body)
    )
    private let storeLabel = UILabel(
        text: ConstantText.store.localize(),
        font: .preferredFont(forTextStyle: .body)
    )
    private let productLabel = UILabel(
        text: ConstantText.product.localize(),
        font: .preferredFont(forTextStyle: .body)
    )
    private let priceLabel = UILabel(
        text: ConstantText.price.localize(),
        font: .preferredFont(forTextStyle: .body)
    )
    
    let storeTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input.localize(),
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    let productNameTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input.localize(),
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    let priceTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input.localize(),
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    private lazy var storeStackView = UIStackView(
        subViews: [storeLabel, storeTextField],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var productStackView = UIStackView(
        subViews: [productLabel, productNameTextField],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var priceStackView = UIStackView(
        subViews: [priceLabel, priceTextField, payTypeSegmented],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var mainStackView = UIStackView(
        subViews: [storeStackView, productStackView, priceStackView],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 20
    )
    
    let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: [ConstantText.cash.localize(), ConstantText.card.localize()])
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        
        return segment
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupDatePicker()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITextField Delegate
extension ComposeInformationView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == priceTextField {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal

            if let input = textField.text?.replacingOccurrences(of: ",", with: "") {
                if let number = formatter.number(from: input) {
                    textField.text = formatter.string(from: number)
                } else {
                    textField.text = ""
                }
            }
        }
    }
}

// MARK: - DatePicker
extension ComposeInformationView {
    @objc private func datePickerWheel(_ sender: UIDatePicker) -> Date? {
        return sender.date
    }
    
    private func setupDatePicker() {
        datePicker.tintColor = .black
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ko-kr")
        datePicker.clipsToBounds = true
        datePicker.layer.cornerRadius = 10
        datePicker.backgroundColor = ConstantColor.registerColor
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
    }
}

// MARK: - UI Constraint
extension ComposeInformationView {
    private func setupView() {
        backgroundColor = ConstantColor.backGrouncColor
        priceTextField.keyboardType = .numberPad
        
        [datePicker, mainStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [dateLabel, datePicker, mainStackView].forEach(addSubview(_:))
        
        [storeTextField, productNameTextField, priceTextField].forEach {
            $0.setPlaceholder(color: .lightGray)
            $0.delegate  = self
            $0.borderStyle = .roundedRect
        }
    }
    
    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dateLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.17),
            priceLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.17),
            storeLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.17),
            productLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.17),
            
            dateLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            
            mainStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
        
        priceTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
