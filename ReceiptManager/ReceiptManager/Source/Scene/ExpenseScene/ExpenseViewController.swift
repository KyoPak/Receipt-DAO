//
//  ExpenseViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class ExpenseViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: ExpenseViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = ExpenseNavigationBar(title: ConstantText.list.localize())
    private let monthControlView = MonthControlView()
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
    
    init(reactor: ExpenseViewReactor, childViewControllers: [UIViewController]) {
        childViewController = childViewControllers[0]
        
        super.init(nibName: nil, bundle: nil)
        
        setupChildView(childViewControllers)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: ExpenseViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension ExpenseViewController {
    private func bindView() {
        navigationBar.searchButton.rx.tap
            .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .bind { self.coordinator?.moveSearchView() }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: ExpenseViewReactor) {
        navigationBar.showModeButton.rx.tap
            .map { Reactor.Action.showModeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthControlView.previousButton.rx.tap
            .map { Reactor.Action.previoutMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthControlView.nextButton.rx.tap
            .map { Reactor.Action.nextMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthControlView.currentButton.rx.tap
            .map { Reactor.Action.todayButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ExpenseViewReactor) {
        reactor.state.map { $0.showMode }
            .distinctUntilChanged()
            .bind { mode in
                self.navigationBar.changShowModeButton(mode)
                
                switch mode {
                case .list:
                    self.childViewController = self.children[0]
                case .calendar:
                    self.childViewController = self.children[1]
                }
                
                self.setupChildViewController()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dateToShow }
            .asDriver(onErrorJustReturn: Date())
            .drive(onNext: { date in
                self.monthControlView.monthLabel.text = DateFormatter.string(from: date)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraints
extension ExpenseViewController {
    private func setupChildViewController() {
        childViewController.view.removeFromSuperview()
        view.addSubview(self.childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        setupContraints()
    }
    
    private func setupChildView(_ child: [UIViewController]) {
        child.forEach { addChild($0) }
    }
    
    private func setupHierarchy() {
        [navigationBar, monthControlView, childViewController.view].forEach { view.addSubview($0) }
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    func setupProperties() {
        [navigationBar, monthControlView, childViewController.view].forEach {
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
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            monthControlView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            monthControlView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            monthControlView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            monthControlView.heightAnchor.constraint(equalToConstant: 50),
            
            childView.topAnchor.constraint(equalTo: monthControlView.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
