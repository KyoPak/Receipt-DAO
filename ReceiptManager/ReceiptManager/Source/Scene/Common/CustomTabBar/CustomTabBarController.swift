//
//  CustomTabBarController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

import RxSwift

final class CustomTabBarController: UITabBarController {
    
    // Properties
    
    private let disposeBag = DisposeBag()
    weak var coordinator: MainTabBarCoordinator?

    // UI Properties
    
    private let customTabBar = CustomTabBar()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupProperties()
        setupConstraints()
        bind()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Bindings
    private func bind() {
        customTabBar.itemTapped
            .bind { [weak self] in
                self?.selectedIndex = $0
            }
            .disposed(by: disposeBag)
        
        customTabBar.registerButtonTapped
            .bind { _ in
                self.coordinator?.showRegister()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraints
extension CustomTabBarController {
    private func setupProperties() {
        tabBar.isHidden = true
        selectedIndex = 0
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupHierarchy() {
        view.addSubview(customTabBar)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
