//
//  ComposeViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

final class ComposeViewController: UIViewController, ViewModelBindable {
    var viewModel: CommonViewModel?
    
    let storeTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = ConstantColor.cellColor
        
        return textField
    }()
    
    let productNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = ConstantColor.cellColor
        
        return textField
    }()
    
    let priceTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = ConstantColor.cellColor
        
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
        textView.backgroundColor = ConstantColor.cellColor
        
        return textView
    }()
    
    lazy var subStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [datePicker, payTypeSegmented])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            storeTextField,
            productNameTextField,
            priceTextField,
            subStackView,
            memoTextView
        ])
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModel() {
        
    }
}

extension ComposeViewController {
    @objc private func datePickerWheel(_ sender: UIDatePicker) -> Date? {
        return sender.date
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
    }
}

extension ComposeViewController {
    private func setupView() {
        view.addSubview(mainStackView)
        view.backgroundColor = ConstantColor.backGrouncColor
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
    }
}
