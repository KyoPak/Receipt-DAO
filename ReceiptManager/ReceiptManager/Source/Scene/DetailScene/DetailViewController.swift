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

enum ComposeAlertActionType {
    case edit
    case delete
}

final class DetailViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: DetailViewCoordinator?
    
    // UI Properties
    
    private let imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.layer.cornerRadius = 10
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = ConstantColor.backGroundColor
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        
        return collectionView
    }()
    
    private let dateLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline))
    private let storeLabel = UILabel(font: .boldSystemFont(ofSize: 20))
    private let productLabel = UILabel(font: .preferredFont(forTextStyle: .body))
    private let priceLabel = UILabel(font: .boldSystemFont(ofSize: 20))
    private let countLabel = UILabel(font: .preferredFont(forTextStyle: .caption1))
    private let separatorView = UIView()
    
    private let payTypeSegmented: UISegmentedControl = {
        let segment = UISegmentedControl(items: [ConstantText.cash.localize(), ConstantText.card.localize()])
        segment.isEnabled = false
        segment.selectedSegmentIndex = .zero
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segment.selectedSegmentTintColor = ConstantColor.subColor
        
        return segment
    }()
    
    private let memoLabel: BasePaddingLabel = {
        let label = BasePaddingLabel()
        label.layer.cornerRadius = 10
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        label.backgroundColor = ConstantColor.backGroundColor
        label.numberOfLines = 5
        return label
    }()
    
    private lazy var priceStackView = UIStackView(
        subViews: [payTypeSegmented, priceLabel],
        axis: .vertical,
        alignment: .trailing,
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
    
    private var mainInfoView = UIView(frame: .zero)
    
    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: ConstantImage.share),
        style: .plain,
        target: self,
        action: nil
    )
    
    private lazy var composeButton = UIBarButtonItem(
        image: UIImage(systemName: ConstantImage.compose),
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
extension DetailViewController: UICollectionViewDelegate {
    private func bindView() {
        imageCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.zip(imageCollectionView.rx.modelSelected(Data.self), imageCollectionView.rx.itemSelected)
            .withUnretained(self)
            .do { (onwer, data) in
                onwer.imageCollectionView.deselectItem(at: data.1, animated: true)
            }
            .map { $1.0 }
            .subscribe { [weak self] in
                self?.coordinator?.presentLargeImage(image: $0)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: DetailViewReactor) {
        composeButton.rx.tap
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.showComposeAlert()
            }
            .map { actionType in
                switch actionType {
                case .edit:
                    return Reactor.Action.edit
                case .delete:
                    return Reactor.Action.delete
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map { Reactor.Action.shareButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: DetailViewReactor) {
        reactor.state.map { $0.title }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expense }
            .withUnretained(self)
            .bind { (owner, item) in
                owner.updateUI(item: item)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.priceText }
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expense.receiptData }
            .asDriver(onErrorJustReturn: [])
            .drive(
                imageCollectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.hiddenDeleteButton()
                cell.setupReceiptImage(data)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shareExpense }
            .compactMap { $0 }
            .withUnretained(self)
            .bind { (owner, datas) in
                owner.presentActivityView(datas: datas)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.editExpense }
            .compactMap { $0 }
            .withUnretained(self)
            .bind { (owner, expense) in
                owner.coordinator?.presentComposeView(expense: expense)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.deleteExpense }
            .compactMap { $0 }
            .withUnretained(self)
            .bind { (owner, _) in
                owner.coordinator?.close(owner)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - ComposeAlert
extension DetailViewController {
    private func showComposeAlert() -> Observable<ComposeAlertActionType> {
        
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let editAction = UIAlertAction(title: ConstantText.edit.localize(), style: .default) { _ in
                observer.onNext(.edit)
                observer.onCompleted()
                alert.dismiss(animated: true)
            }

            let deleteAction = UIAlertAction(
                title: ConstantText.delete.localize(),
                style: .destructive
            ) { _ in
                observer.onNext(.delete)
                observer.onCompleted()
                alert.dismiss(animated: true)
            }
            
            let cancelAction = UIAlertAction(title: ConstantText.cancle.localize(), style: .cancel)
            
            [editAction, deleteAction, cancelAction].forEach(alert.addAction(_:))

            self?.present(alert, animated: true)
            
            return Disposables.create()
        }
    }
}

// MARK: - UI Constraints
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
                
        navigationItem.rightBarButtonItems = [composeButton, shareButton]
    }
    
    private func updateUI(item: Receipt) {
        storeLabel.text = item.store
        productLabel.text = item.product
        memoLabel.text = item.memo
        payTypeSegmented.selectedSegmentIndex = item.paymentType
        shareButton.isEnabled = item.receiptData.count != .zero
        dateLabel.text = DateFormatter.string(from: item.receiptDate, ConstantText.dateFormatFull.localize())
        countLabel.text = item.receiptData.count == .zero ?
            "" : ConstantText.imageCountText.localized(with: String(item.receiptData.count))
        
        setupCollectionViewLayout(count: item.receiptData.count)
    }
    
    private func setupCollectionViewLayout(count: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionCellWidth = view.bounds.width * 0.4
        let collectionCellHeight = view.bounds.height * 0.35
        var spacing = ((UIScreen.main.bounds.width - collectionCellWidth)) / 2

        if count > 1 {
            spacing = (UIScreen.main.bounds.width - (collectionCellWidth * 2)) / CGFloat(count + 1)
        }
        
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        layout.minimumLineSpacing = spacing

        imageCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func setupHierarchy() {
        [dateLabel, mainStackView].forEach(mainInfoView.addSubview(_:))
        [mainInfoView, imageCollectionView, countLabel, memoLabel, separatorView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        priceLabel.textColor = ConstantColor.subColor
        
        memoLabel.backgroundColor = ConstantColor.cellColor
        memoLabel.layer.cornerRadius = 10
        memoLabel.clipsToBounds = true
        
        if payTypeSegmented.selectedSegmentIndex == 0 {
            payTypeSegmented.selectedSegmentTintColor = ConstantColor.mainColor
            priceLabel.textColor = ConstantColor.mainColor
        }
        
        dateLabel.textColor = .systemGray
        mainInfoView.backgroundColor = ConstantColor.cellColor
        mainInfoView.layer.cornerRadius = 10
        
        separatorView.backgroundColor = ConstantColor.cellColor
        
        [mainInfoView, memoLabel, imageCollectionView, memoLabel, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: mainInfoView.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: mainInfoView.leadingAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabel.intrinsicContentSize.height),
            
            mainStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 0),
            mainStackView.leadingAnchor.constraint(equalTo: mainInfoView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: mainInfoView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: mainInfoView.bottomAnchor, constant: -20),
                        
            mainInfoView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            mainInfoView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainInfoView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            mainInfoView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25),
            
            memoLabel.topAnchor.constraint(equalTo: mainInfoView.bottomAnchor, constant: 20),
            memoLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: memoLabel.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: memoLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: memoLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            countLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            countLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            imageCollectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor),
            imageCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageCollectionView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.45)
        ])
        
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
