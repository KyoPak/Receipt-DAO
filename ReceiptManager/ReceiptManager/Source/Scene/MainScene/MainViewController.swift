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
    
    private var headerView = UIView()
    
    private var monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .bold)
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
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension MainViewController {
    private func bindView() {
        navigationBar.searchButton.rx.tap
            .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .bind { self.coordinator?.moveSearchView() }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: MainViewReactor) {
        navigationBar.showModeButton.rx.tap
            .map { Reactor.Action.showModeButtonTapped }
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
            .map { Reactor.Action.todayButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MainViewReactor) {
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
                self.monthLabel.text = DateFormatter.string(from: date)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraints
extension MainViewController {
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
        [navigationBar, headerView, childViewController.view].forEach { view.addSubview($0) }
        [monthLabel, previousButton, nextButton, currentButton].forEach(headerView.addSubview(_:))
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    func setupProperties() {
        [navigationBar, headerView, childViewController.view].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        [monthLabel, previousButton, nextButton, currentButton].forEach {
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
            
            headerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
            
            childView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
