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
        
        let collectionCellWidth = UIScreen.main.bounds.width * 0.7
        
        let spacing = (UIScreen.main.bounds.width - collectionCellWidth - 40) / 2
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = ConstantColor.cellColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        
        return collectionView
    }()
    
    private let dateLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .subheadline))
    private let storeLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 25))
    private let productLabel = UILabel(text: "내역", font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(text: "가격", font: .boldSystemFont(ofSize: 20))
    private let countLabel = UILabel(text: "", font: .preferredFont(forTextStyle: .caption1))
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["현금", "카드"])
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
        textView.textColor = .white
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
        subViews: [dateLabel, storeLabel, productLabel, priceStackView],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
    }
    
    func bindViewModel() {
        changePageLabel(page: 1)
        
        viewModel?.receiptData
            .bind(to: collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
        
        dateLabel.text = DateFormatter.string(
            from: viewModel?.receipt.receiptDate ?? Date(),
            "yyyy년 MM월 dd일"
        )
        storeLabel.text = viewModel?.receipt.store
        productLabel.text = viewModel?.receipt.product
        priceLabel.text = NumberFormatter.numberDecimal(from: viewModel?.receipt.price ?? .zero) + " 원"
        payTypeSegmented.selectedSegmentIndex = viewModel?.receipt.paymentType ?? .zero
        memoTextView.text = viewModel?.receipt.memo
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UICollectionViewDelegate
extension DetailViewController: UICollectionViewDelegate {
    private func changePageLabel(page: Int) {
        let totalCount = (try? viewModel?.receiptData.value().count) ?? .zero
        
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

extension DetailViewController {
    @objc func optionButtonTapped() {
        
    }
    
    @objc func composeButtonTapped() {
        
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
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(optionButtonTapped)
        )
        
        let composeButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(composeButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [composeButton, shareButton]
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        priceLabel.textColor = ConstantColor.registerColor
        dateLabel.textColor = .systemGray6
        
        mainStackView.backgroundColor = ConstantColor.cellColor
        mainStackView.layer.cornerRadius = 10
        mainStackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        mainStackView.isLayoutMarginsRelativeArrangement = true

        [memoTextView, collectionView, memoTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [mainStackView, collectionView, countLabel, memoTextView].forEach(view.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            mainStackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            collectionView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.3),

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
