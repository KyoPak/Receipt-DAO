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
    
    private let picker = UIImagePickerController()
    private let datePicker = UIDatePicker()
    
    private let dateLabel = UILabel(text: "날짜", font: .preferredFont(forTextStyle: .body))
    private let storeLabel = UILabel(text: "상호명", font: .preferredFont(forTextStyle: .body))
    private let productLabel = UILabel(text: "내역", font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(text: "가격", font: .preferredFont(forTextStyle: .body))
    private let countLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .body))
    
    private let storeTextField = UITextField(
        textColor: .white,
        placeholder: ConstantPlaceHolder.input,
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    private let productNameTextField = UITextField(
        textColor: .white,
        placeholder: ConstantPlaceHolder.input,
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    private let priceTextField = UITextField(
        textColor: .white,
        placeholder: ConstantPlaceHolder.input,
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
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["현금", "카드"])
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        
        return segment
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let collectionCellWidth = UIScreen.main.bounds.width / 5 - 10
        
        layout.itemSize  = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = ConstantColor.cellColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        
        return collectionView
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 10
        textView.textColor = .lightGray
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = ConstantPlaceHolder.memo
        textView.backgroundColor = ConstantColor.cellColor
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFirstCell()
        setupNotification()
        setupNavigationBar()
        setupDatePicker()
        setupConstraints()
        createKeyboardDownButton()
    }
    
    private func setupFirstCell() {
        let addImage: UIImage = {
            guard let image = UIImage(systemName: "photo.circle")?.withTintColor(.lightGray) else {
                return UIImage()
            }
            
            let configuration = UIImage.SymbolConfiguration(weight: .ultraLight)
            let thinImage = image.withConfiguration(configuration)
            let tintedThinImage = thinImage.withTintColor(.lightGray)
            
            return tintedThinImage
        }()
        
        viewModel?.addReceiptData(addImage.pngData())
    }
    
    func bindViewModel() {
        viewModel?.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel?.receiptData
            .bind(to: collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
        
        viewModel?.receiptData
            .map { datas in
                return "영수증 등록 \(datas.count - 1)/5"
            }
            .asDriver(onErrorJustReturn: "")
            .drive(countLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                let currentDataCount = (try? self.viewModel?.receiptData.value().count) ?? .zero
                if index.row == .zero && currentDataCount < 6 {
                    self.uploadImageCell(true)
                }
            })
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
            price: Int(priceTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0"),
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
        datePicker.backgroundColor = ConstantColor.registerColor
        datePicker.subviews[.zero].subviews[.zero].subviews[.zero].alpha = .zero
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
    }
}

// MARK: - UIImagePickerController
extension ComposeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.editedImage] as? UIImage {
            let data = image.pngData()
            viewModel?.addReceiptData(data)
        } else {
            if let image = info[.originalImage] as? UIImage {
                let data = image.pngData()
                viewModel?.addReceiptData(data)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextField, TextViewDelagate
extension ComposeViewController: UITextFieldDelegate, UITextViewDelegate {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ConstantPlaceHolder.memo
            textView.textColor = .lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

// MARK: - KeyBoard Response Notification, About KeyBoard
extension ComposeViewController {
    private func createKeyboardDownButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: "keyboard.chevron.compact.down"),
            style: .done,
            target: self,
            action: #selector(keyboardDone)
        )
        
        doneButton.tintColor = .black
        
        toolbar.setItems([flexSpace, doneButton], animated: false)
        memoTextView.inputAccessoryView = toolbar
    }
    
    @objc func keyboardDone() {
        view.endEditing(true)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        keyboardWillHide()
        if let keyboardFrame: NSValue = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? NSValue, memoTextView.isFirstResponder {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc private func keyboardWillHide() {
        if view.frame.origin.y != .zero {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = .zero
            }
        }
    }
}

// MARK: - uploadImageCell
extension ComposeViewController {
    private func uploadImageCell(_ isShowPicker: Bool) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        let alert = UIAlertController(
            title: "영수증 사진선택",
            message: "업로드할 영수증을 선택해주세요.",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let rawAction = UIAlertAction(title: "원본사진", style: .default) { _ in
            self.picker.allowsEditing = false
            self.present(self.picker, animated: true, completion: nil)
        }
        
        let editAction = UIAlertAction(title: "편집사진", style: .default) { _ in
            self.picker.allowsEditing = true
            self.present(self.picker, animated: true, completion: nil)
        }
        
        [rawAction, editAction, cancelAction].forEach(alert.addAction(_:))
        present(alert, animated: true, completion: nil)
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
        picker.delegate = self
        view.backgroundColor = ConstantColor.backGrouncColor
        [datePicker, mainStackView, memoTextView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [dateLabel, datePicker, mainStackView, countLabel, collectionView, memoTextView]
            .forEach(view.addSubview(_:))
        [storeTextField, productNameTextField, priceTextField].forEach {
            $0.setPlaceholder(color: .lightGray)
            $0.delegate = self
            $0.borderStyle = .roundedRect
        }
        
        priceTextField.keyboardType = .numberPad
        memoTextView.delegate = self
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
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            countLabel.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            countLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            countLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 100),
            
            memoTextView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
            memoTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            memoTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30)
        ])
        
        priceTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
