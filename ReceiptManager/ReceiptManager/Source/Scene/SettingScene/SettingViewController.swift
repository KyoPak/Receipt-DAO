//
//  SettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class SettingViewController: UIViewController, View {

    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: SettingViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = CustomNavigationBar(title: ConstantText.setting.localize())
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
    
    init(reactor: SettingViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SettingViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension SettingViewController {
    private func bindView() {
        
    }
    
    private func bindAction(_ reactor: SettingViewReactor) {
        
    }
    
    private func bindState(_ reactor: SettingViewReactor) {
        
    }
}


extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension SettingViewController {
    @objc private func tapCloseButton() {
//        viewModel?.cancelAction()
    }
}

// MARK: - UI Constrints
extension SettingViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHierarchy() {
        [navigationBar, tableView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        tableView.backgroundColor = ConstantColor.backGroundColor
        [navigationBar, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 70),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
