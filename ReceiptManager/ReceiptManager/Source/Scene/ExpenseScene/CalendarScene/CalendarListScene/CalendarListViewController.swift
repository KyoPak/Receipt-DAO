//
//  CalendarListViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CalendarListViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: CalendarListViewCoordinator?
    
    // UI Properties
    
    private let dateLabel = UILabel(font: .systemFont(ofSize: 25, weight: .bold))
    private let weekDayLabel = UILabel(font: .systemFont(ofSize: 20, weight: .bold))
    private let totalAmountLabel = UILabel(font: .systemFont(ofSize: 15))
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Initializer
    
    init(reactor: CalendarListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CalendarListReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension CalendarListViewController {
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
    
    private func bindAction(_ reactor: CalendarListReactor) {
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
    
    private func bindState(_ reactor: CalendarListReactor) {
        reactor.state.map { $0.dateTitle }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.weekIndex }
            .map { ConstantText.weekDay[$0].localize() }
            .bind(to: weekDayLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.amountByDay }
            .map { amount in
                if amount == "" { return "" }
                return ConstantText.amountByDay.localized(with: amount)
            }
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.expenseByDay }
            .bind(to: tableView.rx.items(
                cellIdentifier: ListTableViewCell.identifier,
                cellType: ListTableViewCell.self)
            ) { [weak self] indexPath, data, cell in
                cell.reactor = ListTableViewCellReactor(
                    expense: data,
                    userDefaultEvent: self?.reactor?.currentEvent ?? BehaviorSubject(value: .zero)
                )
            }
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

// MARK: - BottomSheetDismissable Delegate
extension CalendarListViewController: BottomSheetDismissable {
    func bottomSheetDismissable() {
        coordinator?.close(self)
    }
}

// MARK: - UITableViewDelegate
extension CalendarListViewController: UITableViewDelegate {
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
}

// MARK: - UI Constraints
extension CalendarListViewController {
    private func setupHierarchy() {
        [dateLabel, weekDayLabel, totalAmountLabel, tableView].forEach(view.addSubview(_:))
    }
    
    func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        weekDayLabel.textAlignment = .left
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.separatorStyle = .none
        totalAmountLabel.textColor = ConstantColor.mainColor

        [dateLabel, weekDayLabel, totalAmountLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            dateLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            weekDayLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            weekDayLabel.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            
            totalAmountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            totalAmountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            tableView.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        ])
    }
}
