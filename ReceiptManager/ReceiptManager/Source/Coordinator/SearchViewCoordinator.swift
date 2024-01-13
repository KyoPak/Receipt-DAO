//
//  SearchViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

final class SearchViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    
    init(
        mainNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.mainNavigationController = mainNavigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.subNavigationController = UINavigationController()
    }
    
    func start() {
        let expenseRepository = DefaultExpenseRepository(service: storageService)
        let currencyRepository = DefaultCurrencyRepository(service: userDefaultService)
        let searchViewReactor = SearchViewReactor(
            expenseRepository: expenseRepository,
            currencyRepository: currencyRepository
        )
        let searchViewController = SearchViewController(reactor: searchViewReactor)
        subNavigationController?.setViewControllers([searchViewController], animated: true)
        searchViewController.coordinator = self
            
        subNavigationController?.modalPresentationStyle = .fullScreen
        mainNavigationController?.present(subNavigationController ?? UINavigationController(), animated: true)
    }
}

extension SearchViewCoordinator {
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            mainNavigationController: subNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
