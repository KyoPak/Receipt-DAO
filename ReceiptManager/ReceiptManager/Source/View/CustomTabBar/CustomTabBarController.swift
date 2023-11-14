//
//  CustomTabBarController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

import RxSwift

final class CustomTabBarController: UITabBarController {
    let coordinator: SceneCoordinator
    let storage: CoreDataStorage
    
    private let customTabBar = CustomTabBar()
    private let disposeBag = DisposeBag()

    init(coordinator: SceneCoordinator, storage: CoreDataStorage) {
        self.coordinator = coordinator
        self.storage = storage
        
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
    
    private func setupProperties() {
        tabBar.isHidden = true
        selectedIndex = 0
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        let controllers = CustomTabItem.allCases.map {
            return $0.viewController(storage: storage, coordinator: coordinator)
        }
        setViewControllers(controllers, animated: true)
    }
    
    private func setupHierarchy() {
        tabBar.isHidden = true
        
        view.addSubview(customTabBar)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            customTabBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            customTabBar.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            customTabBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    // MARK: - Bindings
    private func bind() {
        customTabBar.itemTapped
            .bind { [weak self] in
                self?.selectedIndex = $0
            }
            .disposed(by: disposeBag)
    }
}
