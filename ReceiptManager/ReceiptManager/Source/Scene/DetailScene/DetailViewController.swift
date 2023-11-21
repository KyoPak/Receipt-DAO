//
//  DetailViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class DetailViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: DetailViewCoordinator?
    
    // UI Properties
    
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
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
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
    
    private let shareButton = UIBarButtonItem(
        image: UIImage(systemName: ConstantImage.share),
        style: .plain,
        target: self,
        action: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
//        scrollToFirstItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            coordinator?.close(self)
        }
    }
    
    // Initializer
    
    init(reactor: DetailViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: DetailViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension DetailViewController {
    private func bindView() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.zip(collectionView.rx.modelSelected(Data.self), collectionView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { (onwer, data) in
                onwer.collectionView.deselectItem(at: data.1, animated: true)
            })
            .map { $1.0 }
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentLargeImage(image: $0)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindAction(_ reactor: DetailViewReactor) {
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map { Reactor.Action.shareButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(scrollViewDidEndDecelerating))
            .map { scrollView in
                let collectionView = scrollView.first as? UICollectionView ?? UICollectionView()
                return Reactor.Action.imageSwipe(collectionView.bounds)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: DetailViewReactor) {
        reactor.state.map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive { self.title = $0 }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expense }
            .asDriver(onErrorJustReturn: Receipt())
            .drive(onNext: { item in
                self.updateUI(item: item)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.priceText }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { priceText in
                self.priceLabel.text = priceText
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dateText }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { dateText in
                self.dateLabel.text = dateText
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expense.receiptData }
            .asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.hiddenButton()
                cell.setupReceiptImage(data)
            }
            .disposed(by: rx.disposeBag)
        
        reactor.state.map { $0.shareExpenseDatas }
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { datas in
                self.presentActivityView(datas: datas)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.imagePageText }
            .asDriver(onErrorJustReturn: "")
            .drive { text in
                self.countLabel.text = text
            }
            .disposed(by: disposeBag)
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
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
        
        var tempCG: CGFloat = .zero
        if velocity.x > .zero { tempCG = ceil(estimatedIndex) }
        if velocity.x < .zero { tempCG = floor(estimatedIndex) }
        if velocity.x == .zero { tempCG = round(estimatedIndex) }
        
        targetContentOffset.pointee = CGPoint(x: tempCG * cellWidthIncludingSpacing, y: .zero)
    }
}

// MARK: - Action
extension DetailViewController {
    @objc private func composeButtonTapped() {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let editAction = UIAlertAction(
//            title: ConstantText.edit.localize(),
//            style: .default
//        ) { [weak self] _ in
//            self?.viewModel?.makeEditAction()
//        }
//
//        let deleteAction = UIAlertAction(
//            title: ConstantText.delete.localize(),
//            style: .destructive
//        ) { [weak self] _ in
//            self?.viewModel?.delete()
//        }
//
//        let cancelAction = UIAlertAction(title: ConstantText.cancle.localize(), style: .cancel)
//        [editAction, deleteAction, cancelAction].forEach(alert.addAction(_:))
//
//        present(alert, animated: true)
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
    
    private func updateUI(item: Receipt) {
        storeLabel.text = item.store
        productLabel.text = item.product
        payTypeSegmented.selectedSegmentIndex = item.paymentType
        memoTextView.text = item.memo
        shareButton.isEnabled = item.receiptData.count != .zero
    }
    
    private func setupHierarchy() {
        [dateLabel, mainStackView].forEach(mainView.addSubview(_:))
        [mainView, collectionView, countLabel, memoTextView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        priceLabel.textColor = ConstantColor.registerColor
        
        if payTypeSegmented.selectedSegmentIndex == 0 {
            payTypeSegmented.selectedSegmentTintColor = ConstantColor.favoriteColor
            priceLabel.textColor = ConstantColor.favoriteColor
        }
        
        dateLabel.textColor = .systemGray
        mainView.backgroundColor = ConstantColor.cellColor
        mainView.layer.cornerRadius = 10
        
        [mainView, memoTextView, collectionView, memoTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
