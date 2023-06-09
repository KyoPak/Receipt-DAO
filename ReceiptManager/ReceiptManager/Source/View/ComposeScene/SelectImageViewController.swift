//
//  SelectImageViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/22.
//

import UIKit
import RxSwift
import RxCocoa

protocol SelectPickerDelegate: AnyObject {
    func selectPicker()
}

class SelectImageViewController: UIViewController, ViewModelBindable, UICollectionViewDelegate {
    var viewModel: SelectImageViewModel?
    private weak var delegate: SelectPickerDelegate?
    
    private var addSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.selectButton, for: .normal)
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
        setupView()
        setupNavigationBar()
        setupConstraint()
    }
    
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
}

extension SelectImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.selectMaxCount > .zero
    }
}

extension SelectImageViewController {
    @objc private func tapCancleButton() {
        viewModel?.closeView()
    }
    
    @objc private func tapSaveButton() {
        viewModel?.selectComplete()
    }
}

extension SelectImageViewController {
    private func setupView() {
        delegate = viewModel?.pickerDelegate
        [addSelectButton, collectionView].forEach(view.addSubview(_:))
        view.backgroundColor = ConstantColor.cellColor
    }
    
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
            title: ConstantText.complete,
            style: .done,
            target: self,
            action: #selector(tapSaveButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func setupConstraint() {
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
