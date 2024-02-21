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
                userDefaultEvent: self.reactor?
                    .userSettingRepository.currencyChangeEvent ?? BehaviorSubject<Int>(value: .zero)
            )
            
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _, _ in return true }
        
        return dataSource
    }()
    
    var disposeBag = DisposeBag()
    weak var coordinator: ListViewCoordinator?
    
    // UI Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.loadData }
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
        reactor.state.map { $0.expenseByMonth }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dataError }
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { [weak self] error in
                self?.coordinator?.presentAlert(error: error)
            }
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

// MARK: - UI Constraints
extension ListViewController {
    private func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30)
        ])
    }
}
