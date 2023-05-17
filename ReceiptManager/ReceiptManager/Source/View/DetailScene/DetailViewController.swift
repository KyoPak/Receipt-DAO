//
//  DetailViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

final class DetailViewController: UIViewController, ViewModelBindable {
    
    var viewModel: DetailViewModel?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let collectionCellWidth = UIScreen.main.bounds.width - 20
        
        layout.itemSize  = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = ConstantColor.cellColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        
        return collectionView
    }()
    
    private let dateLabel = UILabel(text: "날짜", font: .preferredFont(forTextStyle: .body))
    private let storeLabel = UILabel(text: "상호명", font: .preferredFont(forTextStyle: .body))
    private let productLabel = UILabel(text: "내역", font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(text: "가격", font: .preferredFont(forTextStyle: .body))
    private let countLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .body))
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["현금", "카드"])
        segment.isSelected = false
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.registerColor
        
        return segment
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.layer.cornerRadius = 10
        textView.textColor = .lightGray
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = ConstantPlaceHolder.memo
        textView.backgroundColor = ConstantColor.cellColor
        
        return textView
    }()
    
    private lazy var priceStackView = UIStackView(
        subViews: [priceLabel, payTypeSegmented],
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var mainStackView = UIStackView(
        subViews: [dateLabel, storeLabel, productLabel, priceStackView, memoTextView],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 20
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
    }
    
    func bindViewModel() {
        
    }
}

extension DetailViewController {
    @objc func optionButtonTapped() {
        
    }
}

// MARK: - UIConstraint
extension DetailViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ConstantColor.backGrouncColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backItem?.title = "뒤로가기"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(optionButtonTapped)
        )
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        [payTypeSegmented, memoTextView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [collectionView, mainStackView].forEach(view.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            collectionView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.7),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        ])
        
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
