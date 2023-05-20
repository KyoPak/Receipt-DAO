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
import AVFoundation
import PhotosUI

final class ComposeViewController: UIViewController, ViewModelBindable {
    var viewModel: ComposeViewModel?
    private let datePicker = UIDatePicker()
    
    private let placeHoderLabel = UILabel(text: ConstantText.memo, font: .preferredFont(forTextStyle: .body))
    
    private let dateLabel = UILabel(text: ConstantText.date, font: .preferredFont(forTextStyle: .body))
    private let storeLabel = UILabel(text: ConstantText.store, font: .preferredFont(forTextStyle: .body))
    private let productLabel = UILabel(text: ConstantText.product, font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(text: ConstantText.price, font: .preferredFont(forTextStyle: .body))
    private let countLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .body))
    
    private let storeTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input,
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    private let productNameTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input,
        tintColor: ConstantColor.registerColor,
        backgroundColor: ConstantColor.cellColor
    )
    
    private let priceTextField = UITextField(
        textColor: .white,
        placeholder: ConstantText.input,
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
        let segment = UISegmentedControl(items: [ConstantText.cash, ConstantText.card])
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
        let collectionCellWidth = UIScreen.main.bounds.width / 4 - 10
        
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
        textView.textColor = .white
        textView.font = .preferredFont(forTextStyle: .body)
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
            guard let image = UIImage(systemName: "camera.circle")?.withTintColor(.lightGray) else {
                return UIImage()
            }
            
            let configuration = UIImage.SymbolConfiguration(weight: .ultraLight)
            let thinImage = image.withConfiguration(configuration)
            let tintedThinImage = thinImage.withTintColor(.lightGray)
            
            return tintedThinImage
        }()
        
        viewModel?.updateReceiptData(addImage.pngData(), isFirstReceipt: true)
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        // ViewModel Data를 UI 바인딩
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.receipt
            .bind { [weak self] receipt in
                self?.datePicker.date = receipt.receiptDate
                self?.storeTextField.text = receipt.store
                self?.productNameTextField.text = receipt.product
                
                let price = NumberFormatter.numberDecimal(from: receipt.price)
                let priceText = price == "0" ? "" : price
                self?.priceTextField.text = priceText
                self?.payTypeSegmented.selectedSegmentIndex = receipt.paymentType
                self?.memoTextView.text = receipt.memo
                
                if receipt.memo != "" {
                    self?.placeHoderLabel.isHidden = true
                }
                
                self?.countLabel.text = "영수증 등록 \(receipt.receiptData.count - 1)/5"
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.receipt
            .map { $0.receiptData }
            .asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                if indexPath == .zero { cell.hiddenButton() }
                cell.delegate = self
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
        
        // UI의 Data를 ViewModel에 바인딩
        datePicker.rx.date
            .subscribe(onNext: { [weak self] datePickerDate in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                receipt.receiptDate = datePickerDate
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        storeTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                receipt.store = text ?? ""
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        productNameTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                receipt.product = text ?? ""
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        priceTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                let input = text?.replacingOccurrences(of: ",", with: "")
                receipt.price = Int(input ?? "0") ?? .zero
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        payTypeSegmented.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                receipt.paymentType = index
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        memoTextView.rx.text
            .subscribe(onNext: { [weak self] text in
                guard var receipt = try? self?.viewModel?.receipt.value() else { return }
                receipt.memo = text ?? ""
                self?.viewModel?.receipt.onNext(receipt)
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let currentData = (try? self.viewModel?.receipt.value().receiptData) ?? []
                if index.row == .zero && currentData.count < 6 {
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
        datePicker.backgroundColor = ConstantColor.registerColor
        datePicker.subviews[.zero].subviews[.zero].subviews[.zero].alpha = .zero
        datePicker.addTarget(self, action: #selector(datePickerWheel), for: .valueChanged)
    }
}

// MARK: - PHPickerViewControllerDelegate, UIImagePickerController
extension ComposeViewController: UINavigationControllerDelegate,
                                 UIImagePickerControllerDelegate,
                                 PHPickerViewControllerDelegate {
    // PHPickerViewController
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { images, error in
                    DispatchQueue.main.async {
                        let data = (images as? UIImage)?.pngData()
                        self.viewModel?.updateReceiptData(data, isFirstReceipt: false)
                    }
                }
            }
        }
    }
    
    // UIImagePickerController
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.editedImage] as? UIImage {
            let data = image.pngData()
            viewModel?.updateReceiptData(data, isFirstReceipt: false)
        } else {
            if let image = info[.originalImage] as? UIImage {
                let data = image.pngData()
                viewModel?.updateReceiptData(data, isFirstReceipt: false)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UploadImageCell and Confirm Auth
extension ComposeViewController {
    func openPhotoLibrary() {
        let status: PHAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        if status == .authorized || status == .notDetermined {
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration()
                let currentImageCount = (try? viewModel?.receipt.value().receiptData.count) ?? .zero
                
                configuration.selectionLimit = 6 - currentImageCount
                configuration.filter = .any(of: [.images, .livePhotos])
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                present(picker, animated: true, completion: nil)
            } else {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                picker.delegate = self
                present(picker, animated: true, completion: nil)
            }
        } else {
            requestAlbumPermission()
        }
    }
    
    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if status == .authorized || status == .notDetermined {
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        } else {
            requestCameraPermission()
        }
    }
    
    private func uploadImageCell(_ isShowPicker: Bool) {
        let alert = UIAlertController(
            title: "영수증 사진선택",
            message: "업로드할 영수증을 선택해주세요.",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let cameraAction = UIAlertAction(title: "촬영", style: .default) { _ in
            self.openCamera()
        }
        
        let albumAction = UIAlertAction(title: "앨범", style: .default) { _ in
            self.openPhotoLibrary()
        }
        
        [cameraAction, albumAction, cancelAction].forEach(alert.addAction(_:))
        present(alert, animated: true, completion: nil)
    }
    
    func requestAlbumPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            break
        default:
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: "앨범 접근 권한 필요",
                    message: "앨범에 접근하여 사진을 사용할 수 있도록 허용해주세요.",
                    preferredStyle: .alert
                )
                let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            break
        default:
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: "카메라 권한 필요",
                    message: "카메라에 접근하여 사진을 찍을 수 있도록 허용해주세요.",
                    preferredStyle: .alert
                )
                let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
        placeHoderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            placeHoderLabel.isHidden = false
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

// MARK: - Cell Delegate
extension ComposeViewController: CellDeletable {
    func deleteCell(in cell: ImageCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel?.deleteReceiptData(indexPath: indexPath)
    }
}

// MARK: - UIConstraint
extension ComposeViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ConstantColor.backGrouncColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: ConstantText.cancle,
            style: .plain,
            target: self,
            action: #selector(tapCancleButton)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: ConstantText.save,
            style: .done,
            target: self,
            action: #selector(tapSaveButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        
        [datePicker, mainStackView, memoTextView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [dateLabel, datePicker, mainStackView, countLabel, collectionView, memoTextView, placeHoderLabel]
            .forEach(view.addSubview(_:))
        
        [storeTextField, productNameTextField, priceTextField].forEach {
            $0.setPlaceholder(color: .lightGray)
            $0.delegate = self
            $0.borderStyle = .roundedRect
        }
        
        priceTextField.keyboardType = .numberPad
        placeHoderLabel.textColor = .lightGray
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
            collectionView.heightAnchor.constraint(equalToConstant: 140),
            
            memoTextView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
            memoTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            memoTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50),
            
            placeHoderLabel.topAnchor.constraint(equalTo: memoTextView.topAnchor, constant: 10),
            placeHoderLabel.leadingAnchor.constraint(equalTo: memoTextView.leadingAnchor, constant: 5),
            placeHoderLabel.trailingAnchor.constraint(equalTo: memoTextView.trailingAnchor)
        ])
        
        priceTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
