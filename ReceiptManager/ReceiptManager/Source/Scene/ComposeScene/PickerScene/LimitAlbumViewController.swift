//
//  LimitAlbumViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/22.
//

import UIKit
import Photos

import ReactorKit
import RxSwift
import RxCocoa

protocol SelectPickerDelegate: AnyObject {
    func selectPicker()
}

final class LimitAlbumViewController: UIViewController, View {
    
    // Properties
    
    private weak var delegate: SelectPickerDelegate?
    weak var coordinator: LimitAlbumViewCoordinator?
    var disposeBag = DisposeBag()
    
    private var limitedImagesData: [Data] = []
    private var fetchImageResult = PHFetchResult<PHAsset>()
    private var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
    }
    
    // UI Properties
    
    private var addSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.selectButton.localize(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionCellWidth = UIScreen.main.bounds.width / 3 - 3
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImagePickerCell.self, forCellWithReuseIdentifier: ImagePickerCell.identifier)
        collectionView.backgroundColor = ConstantColor.cellColor
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupNavigationBar()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: LimitAlbumViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        accessLimitedImages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func accessLimitedImages() {
        limitedImagesData = []
        
        let fetchOptions = PHFetchOptions()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        fetchImageResult = PHAsset.fetchAssets(with: fetchOptions)
        
        fetchImageResult.enumerateObjects({ asset, _, _ in
            PHImageManager().requestImage(
                for: asset,
                targetSize: self.thumbnailSize,
                contentMode: .aspectFill,
                options: requestOptions
            ) { (image, info) in
                
                guard let image = image else { return }
                self.limitedImagesData.append(image.pngData() ?? Data())
            }
        })
    }
    
    func bind(reactor: LimitAlbumViewReactor) {
        
    }
    
    /*
    func bindViewModel() {
        viewModel?.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel?.selectData
            .asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(
                    cellIdentifier: ImagePickerCell.identifier, cellType: ImagePickerCell.self
                )
            ) { indexPath, data, cell in
                cell.imageView.image = UIImage(data: data)
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe { (owner, indexPath) in
                if let viewModel = owner.viewModel, viewModel.selectMaxCount > .zero {
                    viewModel.selectMaxCount -= 1
                    let data = try? viewModel.selectData.value()[indexPath.item]
                    viewModel.add(data: data)
                }
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemDeselected
            .withUnretained(self)
            .subscribe { (owner, indexPath) in
                let cell = owner.collectionView.cellForItem(at: indexPath) as? ImagePickerCell

                if cell?.isSelected == true {
                    cell?.isSelected = false
                }
                
                guard let viewModel = owner.viewModel else { return }
                
                viewModel.selectMaxCount += 1
                let data = try? viewModel.selectData.value()[indexPath.item]
                viewModel.remove(data: data)
            }
            .disposed(by: rx.disposeBag)
        
        addSelectButton.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { (owner, _) in
                owner.delegate?.selectPicker()
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
     */
}

extension LimitAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
//        guard let viewModel = viewModel else { return false }
//        return viewModel.selectMaxCount > .zero
    }
}

extension LimitAlbumViewController {
    @objc private func tapCancleButton() {
//        viewModel?.closeView()
    }
    
    @objc private func tapSaveButton() {
//        viewModel?.selectComplete()
    }
}


// MARK: - UI Constraints
extension LimitAlbumViewController {
    private func setupHierarchy() {
        [addSelectButton, collectionView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.cellColor
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ConstantColor.backGroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: ConstantText.cancle.localize(),
            style: .plain,
            target: self,
            action: #selector(tapCancleButton)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: ConstantText.complete.localize(),
            style: .done,
            target: self,
            action: #selector(tapSaveButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            addSelectButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            addSelectButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            addSelectButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            collectionView.topAnchor.constraint(equalTo: addSelectButton.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
}
