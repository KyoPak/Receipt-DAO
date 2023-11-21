//
//  ComposeViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation
import PhotosUI
import Mantis

final class ComposeViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: ComposeViewCoordinator?
    
    private var canAccessImagesData: [Data] = []
    private var fetchResult = PHFetchResult<PHAsset>()
    private var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
    }

    var viewModel: ComposeViewModel?
    
    // UI Properties
    
    private let informationView = ComposeInformationView()
    private let placeHoderLabel = UILabel(
        text: ConstantText.memo.localize(),
        font: .preferredFont(forTextStyle: .body)
    )
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let collectionCellWidth = UIScreen.main.bounds.width / 4 - 10
        
        layout.itemSize  = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = ConstantColor.backGroundColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        
        return collectionView
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 10
        textView.textColor = .label
        textView.layer.borderWidth = 1
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = ConstantColor.cellColor
        textView.layer.borderColor = ConstantColor.layerColor.cgColor
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupNotification()
        setupConstraints()
        createKeyboardDownButton()
    }
    
    // Initializer
    
    init(reactor: ComposeViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: ComposeViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension ComposeViewController {
    private func bindView() {
        
    }
    
    private func bindAction(_ reactor: ComposeViewReactor) {
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ComposeViewReactor) {
        reactor.state.map { $0.transitionType }
            .bind { type in
                switch type {
                case .push:     self.setupNavigationBar()
                case .modal:    self.setupModalNavigationBar()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.title }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expense }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .do { self.placeHoderLabel.isHidden = !$0.memo.isEmpty }
            .drive { self.setupData(item: $0) }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.priceText }
            .asDriver(onErrorJustReturn: "")
            .drive { text in
                self.informationView.priceTextField.text = text
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.registerdImageDatas }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.delegate = self
                cell.setupCountLabel(reactor.currentState.registerdImageDatas.count)
                
                if indexPath == .zero {
                    cell.hiddenDeleteButton()
                    cell.showRegisterButton()
                }
                
                if indexPath != .zero {
                    cell.setupReceiptImage(data)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Action
extension ComposeViewController {
    @objc private func tapCancleButton() {
        coordinator?.close(navigationController ?? UINavigationController())
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
                        if let image = images as? UIImage {
                            self.moveMantis(image: image)
                        }
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
                dismiss(animated: true, completion: {
                    self.moveMantis(image: image)
                })
            }
        }
    }
}

// MARK: - Mantis : CropViewControllerDelegate Method
extension ComposeViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(
        _ cropViewController: CropViewController,
        cropped: UIImage,
        transformation: Transformation,
        cropInfo: CropInfo
    ) {
        let data = cropped.pngData()
        viewModel?.updateReceiptData(data, isFirstReceipt: false)
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(
        _ cropViewController: Mantis.CropViewController,
        original: UIImage
    ) {
        cropViewController.dismiss(animated: true)
    }
    
    private func moveMantis(image: UIImage) {
        var config = Mantis.Config()
        config.cropViewConfig.cropShapeType = .rect
        config.cropViewConfig.builtInRotationControlViewType = .rotationDial()
        
        let imageCropViewController = Mantis.cropViewController(image: image, config: config)
        imageCropViewController.delegate = self
        
        present(imageCropViewController, animated: true)
    }
}

extension ComposeViewController: SelectPickerDelegate {
    func selectPicker() {
        viewModel?.cancelAction(completion: {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        })
    }
}

// MARK: - PHPhotoLibraryChangeObserver
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
extension ComposeViewController: CameraAlbumAccessAlertPresentable {
    func openAlbum() {
        requestPHPhotoLibraryAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .any(of: [.images, .livePhotos])
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                
                self.present(picker, animated: true, completion: nil)
            case .limited:
                PHPhotoLibrary.shared().register(self)
                self.getCanAccessImages()
            default:
                self.showPermissionAlert(text: ConstantText.album.localize())
            }
        }
    }
    
    func openCamera() {
        requestCameraAuthorization { isAuth in
            if !isAuth {
                self.showPermissionAlert(text: ConstantText.camera.localize())
            } else {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
        }
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
            image: UIImage(systemName: ConstantImage.keyboardDown),
            style: .done,
            target: self,
            action: #selector(keyboardDone)
        )
        
        doneButton.tintColor = .label
        
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
    private func setupData(item: Receipt) {
        informationView.datePicker.date = item.receiptDate
        informationView.storeTextField.text = item.store
        informationView.productNameTextField.text = item.product
        informationView.payTypeSegmented.selectedSegmentIndex = item.paymentType
        informationView.priceTextField.text = item.priceText
        memoTextView.text = item.memo
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ConstantColor.backGroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: ConstantText.save.localize(),
            style: .done,
            target: self,
            action: #selector(tapSaveButton)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func setupModalNavigationBar() {
        setupNavigationBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: ConstantText.cancle.localize(),
            style: .plain,
            target: self,
            action: #selector(tapCancleButton)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func setupHierarchy() {
        [informationView, collectionView, memoTextView, placeHoderLabel].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        [informationView, memoTextView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

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
            
            collectionView.topAnchor.constraint(equalTo: informationView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 140),
            
            memoTextView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            memoTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            memoTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50),
            
            placeHoderLabel.topAnchor.constraint(equalTo: memoTextView.topAnchor, constant: 10),
            placeHoderLabel.leadingAnchor.constraint(equalTo: memoTextView.leadingAnchor, constant: 5),
            placeHoderLabel.trailingAnchor.constraint(equalTo: memoTextView.trailingAnchor)
        ])
    }
}
