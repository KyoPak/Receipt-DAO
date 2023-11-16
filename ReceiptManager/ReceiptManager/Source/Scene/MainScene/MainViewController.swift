//
//  MainViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: MainViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = ExpenseNavigationBar(title: ConstantText.list.localize())
    private var childViewController: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    // Initializer
    
    init(reactor: MainViewReactor, childViewControllers: [UIViewController]) {
        // 추후, 상태값에 따라서 초기 설정해줘야함.
        childViewController = childViewControllers[0]
        
        super.init(nibName: nil, bundle: nil)
        
        setupChildView(childViewControllers)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MainViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension MainViewController {
    private func bindView(_ reactor: MainViewReactor) {
        
    }
    
    private func bindAction(_ reactor: MainViewReactor) {
        navigationBar.searchButton.rx.tap
            .map { Reactor.Action.searchButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MainViewReactor) {
        reactor.state.map { $0.isRegister }
            .bind { print("TAP REGISTER", $0) }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSearch }
            .bind { print("TAP SEARCH", $0) }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraints
extension MainViewController {
    private func setupChildView(_ child: [UIViewController]) {
        child.forEach { addChild($0) }
    }
    
    private func setupHierarchy() {
        [navigationBar, childViewController.view].forEach { view.addSubview($0) }
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    func setupProperties() {
        [navigationBar, childViewController.view].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        let childView: UIView = childViewController.view
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 70),
            
            childView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
