//
//  DetailViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: UIViewController, ViewModelBindable {
    var viewModel: DetailViewModel?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionCellWidth = UIScreen.main.bounds.width * 0.7
        
        let spacing = ((UIScreen.main.bounds.width - collectionCellWidth) - 40) / 2
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing * 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = ConstantColor.cellColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        
        return collectionView
    }()
    
    private let dateLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline))
    private let storeLabel = UILabel(font: .boldSystemFont(ofSize: 25))
    private let productLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(font: .boldSystemFont(ofSize: 20))
    private let countLabel = UILabel(font: .preferredFont(forTextStyle: .caption1))
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: [ConstantText.cash.localize(), ConstantText.card.localize()])
        segment.isEnabled = false
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
        textView.textColor = .label
        textView.font = .preferredFont(forTextStyle: .body)
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
        subViews: [storeLabel, productLabel, priceStackView],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 5
    )
    
    private var mainView = UIView(frame: .zero)
    
    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: ConstantImage.share),
        style: .plain,
        target: self,
        action: #selector(shareButtonTapped)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToFirstItem()
        changePageLabel(page: 1)
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.receipt
            .asDriver(onErrorJustReturn: Receipt())
            .drive(onNext: { [weak self] receipt in
                self?.dateLabel.text = DateFormatter.string(
                    from: receipt.receiptDate,
                    ConstantText.dateFormatDay.localize()
                )
                self?.storeLabel.text = receipt.store
                self?.productLabel.text = receipt.product
                self?.priceLabel.text = NumberFormatter
                    .numberDecimal(from: receipt.priceText) + viewModel.currency
                self?.payTypeSegmented.selectedSegmentIndex = receipt.paymentType
                self?.memoTextView.text = receipt.memo
                self?.shareButton.isEnabled = receipt.receiptData.count != .zero
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.receipt
            .map { $0.receiptData }
            .asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.hiddenButton()
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
        
        Observable.zip(collectionView.rx.modelSelected(Data.self), collectionView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { (onwer, data) in
                onwer.collectionView.deselectItem(at: data.1, animated: true)
            })
            .map { $1.0 }
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.largeImageAction(data: $0)
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UICollectionViewDelegate
extension DetailViewController: UICollectionViewDelegate {
    private func scrollToFirstItem() {
        let firstIndexPath = IndexPath(item: .zero, section: .zero)
        if collectionView.numberOfItems(inSection: .zero) > .zero {
            collectionView.scrollToItem(at: firstIndexPath, at: .left, animated: true)
        }
    }
    
    private func changePageLabel(page: Int) {
        let receiptData = (try? viewModel?.receipt.value().receiptData) ?? []
        let totalCount = receiptData.count
        
        if totalCount == .zero {
            countLabel.text = ConstantText.noPicture.localize()
            return
        }
        
        countLabel.text = "\(page)/\(totalCount)"
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleBounds = collectionView.bounds
        let currentPage = Int(visibleBounds.midX / visibleBounds.width) + 1
        
        changePageLabel(page: currentPage)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
        
        let tempCG: CGFloat
        if velocity.x > .zero {
            tempCG = ceil(estimatedIndex)
        } else if velocity.x < .zero {
            tempCG = floor(estimatedIndex)
        } else {
            tempCG = round(estimatedIndex)
        }
        
        targetContentOffset.pointee = CGPoint(x: tempCG * cellWidthIncludingSpacing, y: .zero)
    }
}

// MARK: - Action
extension DetailViewController {
    @objc private func shareButtonTapped() {
        let receipt = (try? viewModel?.receipt.value()) ?? Receipt()
        presentActivityView(data: receipt)
    }
    
    @objc private func composeButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(
            title: ConstantText.edit.localize(),
            style: .default
        ) { [weak self] _ in
            self?.viewModel?.makeEditAction()
        }
        
        let deleteAction = UIAlertAction(
            title: ConstantText.delete.localize(),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel?.delete()
        }
        
        let cancelAction = UIAlertAction(title: ConstantText.cancle.localize(), style: .cancel)
        [editAction, deleteAction, cancelAction].forEach(alert.addAction(_:))
        
        present(alert, animated: true)
    }
}

// MARK: - UIConstraint
extension DetailViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ConstantColor.backGroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
                
        let composeButton = UIBarButtonItem(
            image: UIImage(systemName: ConstantImage.compose),
            style: .plain,
            target: self,
            action: #selector(composeButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [composeButton, shareButton]
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGroundColor
        priceLabel.textColor = ConstantColor.registerColor
        
        if payTypeSegmented.selectedSegmentIndex == 0 {
            payTypeSegmented.selectedSegmentTintColor = ConstantColor.favoriteColor
            priceLabel.textColor = ConstantColor.favoriteColor
        }
        
        dateLabel.textColor = .systemGray
        mainView.backgroundColor = ConstantColor.cellColor
        mainView.layer.cornerRadius = 10
        
        [dateLabel, mainStackView].forEach(mainView.addSubview(_:))
        [mainView, memoTextView, collectionView, memoTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [mainView, collectionView, countLabel, memoTextView].forEach(view.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabel.intrinsicContentSize.height),
            
            mainStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20),
            
            productLabel.heightAnchor.constraint(equalToConstant: productLabel.intrinsicContentSize.height),
            
            mainView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            mainView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            mainView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25),
            
            collectionView.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.4),

            countLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 5),
            countLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            memoTextView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 20),
            memoTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            memoTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30)
        ])
        
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
