//
//  ComposeViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class ComposeViewController: UIViewController, ViewModelBindable {
    var viewModel: ComposeViewModel?
    
    let datePicker = UIDatePicker()
    
    private let dateLabel = UILabel(text: "날짜", font: .preferredFont(forTextStyle: .body))
    private let storeLabel = UILabel(text: "상호명", font: .preferredFont(forTextStyle: .body))
    private let productLabel = UILabel(text: "내역", font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(text: "가격", font: .preferredFont(forTextStyle: .body))
    
    private let storeTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.placeholder = ConstantPlaceHolder.input
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    private lazy var storeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [storeLabel, storeTextField])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let productNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.placeholder = ConstantPlaceHolder.input
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    private lazy var productStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productLabel, productNameTextField])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.placeholder = ConstantPlaceHolder.input
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["현금", "카드"])
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        
        return segment
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceLabel, priceTextField, payTypeSegmented])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()

    private lazy var collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionCellWidth = view.window?.windowScene?.screen.bounds.width ?? .zero / 3 - 10
        
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.text = ConstantPlaceHolder.memo
        textView.backgroundColor = ConstantColor.cellColor
        
        return textView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [storeStackView, productStackView, priceStackView])
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupDatePicker()
        setupConstraints()
    }
    
    func bindViewModel() {
        viewModel?.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Action
extension ComposeViewController {
    @objc private func tapCancleButton() {
        viewModel?.cancelAction()
    }
    
    @objc private func tapSaveButton() {
        viewModel?.saveAction(
            store: storeTextField.text,
            product: productNameTextField.text,
            price: Int(priceTextField.text ?? "0"),
            date: datePicker.date,
            payType: PayType(rawValue: payTypeSegmented.selectedSegmentIndex) ?? .cash,
            memo: memoTextView.text,
            receiptData: [])
    }
}

// MARK: - DatePicker
extension ComposeViewController {
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
        datePicker.subviews[0].subviews[0].subviews[0].alpha = 0
        datePicker.backgroundColor = ConstantColor.registerColor
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
    }
}

extension ComposeViewController {
    private func setupCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
    }
}

// MARK: - UIConstraint
extension ComposeViewController {
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(tapCancleButton)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "등록",
            style: .done,
            target: self,
            action: #selector(tapSaveButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        
        [dateLabel, datePicker, mainStackView].forEach(view.addSubview(_:))
        [storeTextField, productNameTextField, priceTextField].forEach {
            $0.setPlaceholder(color: .lightGray)
        }
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dateLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.15),
            priceLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.15),
            storeLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.15),
            productLabel.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.15),
            
            dateLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            
            mainStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
    }
}
