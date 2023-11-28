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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.layer.cornerRadius = 10
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = ConstantColor.backGroundColor
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
    
    let composeButton = UIBarButtonItem(
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
extension DetailViewController: UICollectionViewDelegate {
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
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: DetailViewReactor) {
        composeButton.rx.tap
            .flatMap { self.showComposeAlert() }
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
        
        reactor.state.map { $0.expense.receiptData }
            .asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(cellIdentifier: ImageCell.identifier, cellType: ImageCell.self)
            ) { indexPath, data, cell in
                cell.hiddenDeleteButton()
                cell.setupReceiptImage(data)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shareExpense }
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
        
        reactor.state.map { $0.editExpense }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive { expense in
                self.coordinator?.presentComposeView(expense: expense)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.deleteExpense }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive { _ in
                self.coordinator?.close(self)
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

            let deleteAction = UIAlertAction(title: ConstantText.delete.localize(), style: .destructive) { _ in
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
                
        navigationItem.rightBarButtonItems = [composeButton, shareButton]
    }
    
    private func updateUI(item: Receipt) {
        storeLabel.text = item.store
        productLabel.text = item.product
        memoTextView.text = item.memo
        payTypeSegmented.selectedSegmentIndex = item.paymentType
        shareButton.isEnabled = item.receiptData.count != .zero
        dateLabel.text = DateFormatter.string(from: item.receiptDate, ConstantText.dateFormatDay.localize())
        
        setupCollectionViewLayout(count: item.receiptData.count)
    }
    
    private func setupCollectionViewLayout(count: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        var collectionCellWidth = UIScreen.main.bounds.width * 0.6
        var spacing = ((UIScreen.main.bounds.width - collectionCellWidth)) / 2

        if count > 2 {
            collectionCellWidth = UIScreen.main.bounds.width * 0.4
            spacing = (UIScreen.main.bounds.width - (collectionCellWidth * 2)) / CGFloat(count + 1)
        }
        
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellWidth)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.minimumLineSpacing = spacing

        collectionView.setCollectionViewLayout(layout, animated: true)
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
            
            memoTextView.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 20),
            memoTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            memoTextView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.25),
            
            countLabel.topAnchor.constraint(equalTo: memoTextView.bottomAnchor, constant: 10),
            countLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.4)
        ])
        
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        payTypeSegmented.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        payTypeSegmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
