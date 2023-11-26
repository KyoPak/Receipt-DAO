//
//  BookMarkViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

import ReactorKit
import RxDataSources
import RxSwift
import RxCocoa

final class BookMarkViewController: UIViewController, View {
    
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
    weak var coordinator: BookMarkViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = CustomNavigationBar(title: ConstantText.bookMark.localize())
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: BookMarkViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: BookMarkViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
    
//    func bindViewModel() {
//        Observable.zip(tableView.rx.modelSelected(Receipt.self), tableView.rx.itemSelected)
//            .withUnretained(self)
//            .do(onNext: { (owner, data) in
//                owner.tableView.deselectRow(at: data.1, animated: true)
//            })
//            .map { $1.0 }
//            .subscribe { [weak self] in
//                self?.viewModel?.moveDetailAction(receipt: $0)
//            }
//            .disposed(by: rx.disposeBag)
//    }
}

// MARK: - Reactor Bind
extension BookMarkViewController {
    private func bindView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: BookMarkViewReactor) {
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: BookMarkViewReactor) {
        reactor.state.map { $0.expenseByBookMark }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension BookMarkViewController: UITableViewDelegate {
//    func tableView(
//        _ tableView: UITableView,
//        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
//    ) -> UISwipeActionsConfiguration? {
//        let favoriteAction = UIContextualAction(
//            style: .destructive,
//            title: nil,
//            handler: { [weak self] _, _, completion in
//                self?.viewModel?.favoriteAction(indexPath: indexPath)
//                completion(true)
//            }
//        )
//        favoriteAction.image = UIImage(systemName: ConstantImage.bookMarkRemove)
//
//        return UISwipeActionsConfiguration(actions: [favoriteAction])
//    }
//
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

// MARK: - UIConstraint
extension BookMarkViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHierarchy() {
        [navigationBar, tableView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        [navigationBar, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
