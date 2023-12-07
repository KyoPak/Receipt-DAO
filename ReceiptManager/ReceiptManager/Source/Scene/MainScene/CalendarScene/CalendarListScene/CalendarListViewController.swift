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
    
    // UI Properties
    
    private let dateLabel = UILabel(font: .systemFont(ofSize: 25, weight: .bold))
    private let weekDayLabel = UILabel(font: .systemFont(ofSize: 20, weight: .bold))
    private let totalAmountLabel = UILabel(font: .systemFont(ofSize: 20))
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
        
    }
    
    private func bindAction(_ reactor: CalendarListReactor) {
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.loadView }
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
    }
}

// MARK: - UIConstraints
extension CalendarListViewController {
    private func setupHierarchy() {
        [dateLabel, weekDayLabel, totalAmountLabel, tableView].forEach(view.addSubview(_:))
    }
    
    func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        tableView.backgroundColor = ConstantColor.backGroundColor
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
            weekDayLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            
            totalAmountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            totalAmountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            tableView.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
