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
    private var canAccessImagesData: [Data] = []
    private var fetchResult = PHFetchResult<PHAsset>()
    private var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
    }

    var viewModel: ComposeViewModel?
    
    private let informationView = ComposeInformationView()
    private let placeHoderLabel = UILabel(text: ConstantText.memo, font: .preferredFont(forTextStyle: .body))
    
    private let countLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .body))
    
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
        bindViewModeltoUI()
        bindUItoViewModel()
    }
    
    private func bindViewModeltoUI() {
        guard let viewModel = viewModel else { return }
        
        // ViewModel Data를 UI 바인딩
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.dateRelay
            .asDriver(onErrorJustReturn: Date())
            .drive(informationView.datePicker.rx.date)
            .disposed(by: rx.disposeBag)
        
        viewModel.storeRelay
            .asDriver(onErrorJustReturn: "")
            .drive(informationView.storeTextField.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.productRelay
            .asDriver(onErrorJustReturn: "")
            .drive(informationView.productNameTextField.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.priceRelay
            .asDriver(onErrorJustReturn: .zero)
            .map { price in
                let priceText = NumberFormatter.numberDecimal(from: price)
                return priceText == "0" ? "" : priceText
            }
            .drive(informationView.priceTextField.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.payRelay
            .asDriver(onErrorJustReturn: .zero)
            .drive(informationView.payTypeSegmented.rx.selectedSegmentIndex)
            .disposed(by: rx.disposeBag)
        
        viewModel.memoRelay
            .asDriver(onErrorJustReturn: "")
            .map { [weak self] text in
                if text != "" {
                    self?.placeHoderLabel.isHidden = true
                }
                return text
            }
            .drive(memoTextView.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.receiptDataRelay
            .asDriver()
            .map { datas in
                return "영수증 등록 \(datas.count - 1)/5"
            }
            .drive(countLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.receiptDataRelay
            .asDriver()
            .drive(collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                if indexPath == .zero { cell.hiddenButton() }
                cell.delegate = self
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func bindUItoViewModel() {
        guard let viewModel = viewModel else { return }
        
        // UI의 Data를 ViewModel에 바인딩
        informationView.datePicker.rx.date
            .bind(to: viewModel.dateRelay)
            .disposed(by: rx.disposeBag)
        
        informationView.storeTextField.rx.text.orEmpty
            .bind(to: viewModel.storeRelay)
            .disposed(by: rx.disposeBag)
        
        informationView.productNameTextField.rx.text.orEmpty
            .bind(to: viewModel.productRelay)
            .disposed(by: rx.disposeBag)
        
        informationView.priceTextField.rx.text.orEmpty
            .map { price in
                let input = price.replacingOccurrences(of: ",", with: "")
                return Int(input) ?? .zero
            }
            .bind(to: viewModel.priceRelay)
            .disposed(by: rx.disposeBag)
            
        informationView.payTypeSegmented.rx.selectedSegmentIndex
            .bind(to: viewModel.payRelay)
            .disposed(by: rx.disposeBag)
        
        memoTextView.rx.text.orEmpty
            .bind(to: viewModel.memoRelay)
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if index.row == .zero && viewModel.receiptDataRelay.value.count < 6 {
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

extension ComposeViewController: SelectPickerDelegate {
    func selectPicker() {
        viewModel?.cancelAction(completion: {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        })
    }
}

extension ComposeViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getCanAccessImages()
    }
    
    private func getCanAccessImages() {
        canAccessImagesData = []
        let fetchOptions = PHFetchOptions()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        fetchResult.enumerateObjects({ asset, _, _ in
            PHImageManager().requestImage(
                for: asset,
                targetSize: self.thumbnailSize,
                contentMode: .aspectFill,
                options: requestOptions
            ) { (image, info) in
                
                guard let image = image else { return }
                self.canAccessImagesData.append(image.pngData() ?? Data())
            }
        })
        
        DispatchQueue.main.async {
            self.viewModel?.selectImageAction(selectDatas: self.canAccessImagesData, delegate: self)
        }
    }
}

// MARK: - UploadImageCell and Confirm Auth
extension ComposeViewController {
    private func requestPHPhotoLibraryAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { authorizationStatus in
            DispatchQueue.main.async {
                completion(authorizationStatus)
            }
        })
    }
    
    private func openAlbum() {
        requestPHPhotoLibraryAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                var configuration = PHPickerConfiguration()
                let currentImageCount = self.viewModel?.receiptDataRelay.value.count ?? .zero
                
                configuration.selectionLimit = 6 - currentImageCount
                configuration.filter = .any(of: [.images, .livePhotos])
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
                
            case .limited:
                PHPhotoLibrary.shared().register(self)
                self.getCanAccessImages()
            default:
                self.showPermissionAlert(text: ConstantText.album)
            }
        }
    }
    
    private func requestCameraAuthorization(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { isAuth in
            DispatchQueue.main.async {
                completion(isAuth)
            }
        }
    }
    
    private func openCamera() {
        requestCameraAuthorization { isAuth in
            if !isAuth {
                self.showPermissionAlert(text: ConstantText.camera)
            } else {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
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
            self.openAlbum()
        }
        
        [cameraAction, albumAction, cancelAction].forEach(alert.addAction(_:))
        present(alert, animated: true, completion: nil)
    }
    
    private func showPermissionAlert(text: String) {
        let alertController = UIAlertController(
            title: "\(text) 접근 권한 필요",
            message: "\(text)에 접근하여 사진을 사용할 수 있도록 허용해주세요.",
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
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TextViewDelagate
extension ComposeViewController: UITextViewDelegate {
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
        
        [informationView, memoTextView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [informationView, countLabel, collectionView, memoTextView, placeHoderLabel]
            .forEach(view.addSubview(_:))

        placeHoderLabel.textColor = .lightGray
        memoTextView.delegate = self
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            informationView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            informationView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            informationView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            informationView.heightAnchor.constraint(equalToConstant: 200),
            
            countLabel.topAnchor.constraint(equalTo: informationView.bottomAnchor, constant: 20),
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
    }
}
