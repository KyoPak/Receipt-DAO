//
//  ListViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

typealias ReceiptSectionModel = AnimatableSectionModel<String, Receipt>

final class ListViewController: UIViewController, View {
    
    // Properties
    
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    private lazy var dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, receipt in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier, for: indexPath
            ) as? ListTableViewCell else {
                let cell = UITableViewCell()
                return cell
            }
            
            cell.reactor = ListTableViewCellReactor(
                expense: receipt,
                userDefaultEvent: self.reactor?.userDefaultEvent ?? BehaviorSubject<Int>(value: .zero)
            )
            
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _, _ in return true }
        
        return dataSource
    }()
    
    var disposeBag = DisposeBag()
    weak var coordinator: ListViewCoordinator?
    
    // UI Properties
    
    private var headerView = UIView()
    
    private var monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private var previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronLeft), for: .normal)
        return button
    }()
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronRight), for: .normal)
        return button
    }()
    
    private var currentButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.today.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = ConstantColor.cellColor
        button.layer.cornerRadius = 5
        return button
    }()
    
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: ListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: ListViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension ListViewController {
    private func bindView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Receipt.self), tableView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { (owner, data) in
                owner.tableView.deselectRow(at: data.1, animated: true)
            })
            .map { $1.0 }
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentDetailView(expense: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: ListViewReactor) {
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .map { Reactor.Action.previoutMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.nextMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        currentButton.rx.tap
            .map { Reactor.Action.currentMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(bookmarkCell))
            .flatMap { params -> Observable<IndexPath> in
                guard let indexPath = params.first as? IndexPath else { return Observable.empty() }
                return Observable.just(indexPath)
            }
            .map { Reactor.Action.cellBookMark($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(deleteCell))
            .flatMap { params -> Observable<IndexPath> in
                guard let indexPath = params.first as? IndexPath else { return Observable.empty() }
                return Observable.just(indexPath)
            }
            .map { Reactor.Action.cellDelete($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ListViewReactor) {
        reactor.state.map { $0.dateText }
            .asDriver(onErrorJustReturn: "")
            .drive(monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expenseByMonth }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    @objc dynamic func bookmarkCell(indexPath: IndexPath) { }
    @objc dynamic func deleteCell(indexPath: IndexPath) { }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] _, _, completion in
            
            self?.deleteCell(indexPath: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: ConstantImage.trash)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] _, _, completion in
                
                self?.bookmarkCell(indexPath: indexPath)
                completion(true)
            }
        )
        favoriteAction.backgroundColor = .systemYellow
        favoriteAction.image = UIImage(systemName: ConstantImage.bookMarkSwipe)
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = dataSource[section]
        
        let headerText = data.identity
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .label
        label.text = headerText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 해당 방법은 HeaderView라는 식별자를 가진 View를 새로 만든다.
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "HeaderView")
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UIConstraint
extension ListViewController {
    private func setupHierarchy() {
        [headerView, tableView].forEach(view.addSubview(_:))
        [monthLabel, previousButton, nextButton, currentButton].forEach(headerView.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        tableView.backgroundColor = ConstantColor.backGroundColor
        
        [headerView, monthLabel, previousButton, nextButton, currentButton, tableView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 40),
            previousButton.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -5),
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 45),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 5),
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            currentButton.widthAnchor.constraint(equalToConstant: 60),
            currentButton.heightAnchor.constraint(equalToConstant: 30),
            currentButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            currentButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
