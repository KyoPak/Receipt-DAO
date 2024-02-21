//
//  DetailSettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class DetailSettingViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: DetailSettingCoordinator?
    
    // UI Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
    
    // Initializer
    
    init(reactor: DetailSettingReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: DetailSettingReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension DetailSettingViewController {
    private func bindView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: DetailSettingReactor) {
        
    }
    
    private func bindState(_ reactor: DetailSettingReactor) {
        reactor.state.map { $0.title }
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.detailOptions }
            .bind(to: tableView.rx.items(
                cellIdentifier: OptionCell.identifier,
                cellType: OptionCell.self)
            ) { indexPath, data, cell in
                cell.setupData(optionText: data)
            }
            .disposed(by: disposeBag)
    }
}

extension DetailSettingViewController: UITableViewDelegate { }

// MARK: - UI Constraints
extension DetailSettingViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ConstantColor.backGroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
