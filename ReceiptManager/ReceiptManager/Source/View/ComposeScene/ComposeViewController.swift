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

extension UITextField {
    func setPlaceholder(color: UIColor) {
        guard let string = self.placeholder else {
            return
        }
        attributedPlaceholder = NSAttributedString(string: string, attributes: [.foregroundColor: color])
    }
}

final class ComposeViewController: UIViewController, ViewModelBindable {
    var viewModel: ComposeViewModel?
    
    /*
    UI 수정할 사항
     상호명
     품목 날짜
     가격 타입 
     */
    
    let storeTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.placeholder = ConstantPlaceHolder.store
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    let productNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.placeholder = ConstantPlaceHolder.product
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    let priceTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.tintColor = ConstantColor.registerColor
        textField.backgroundColor = ConstantColor.cellColor
        textField.placeholder = ConstantPlaceHolder.price
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    let datePicker = UIDatePicker()
    
    let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["현금", "카드"])
        segment.selectedSegmentIndex = .zero
        
        return segment
    }()

    lazy var collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionCellWidth = view.window?.windowScene?.screen.bounds.width ?? .zero / 3 - 10
        
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.text = ConstantPlaceHolder.memo
        textView.backgroundColor = ConstantColor.cellColor
        
        return textView
    }()
    
    lazy var subStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [datePicker, payTypeSegmented])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    lazy var mainStackView: UIStackView = {
        [storeTextField, productNameTextField, priceTextField].forEach {
            $0.setPlaceholder(color: .lightGray)
        }
        let stackView = UIStackView(arrangedSubviews: [storeTextField, productNameTextField, priceTextField])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        
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
        viewModel?.saveAction()
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
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
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
        view.addSubview(mainStackView)
        view.backgroundColor = ConstantColor.backGrouncColor
        view.addSubview(subStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        subStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: subStackView.topAnchor, constant: -10),
            
            subStackView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 10),
            subStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10)
        ])
    }
}
