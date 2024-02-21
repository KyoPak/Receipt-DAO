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
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    
    init(
        mainNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
        self.subNavigationController = UINavigationController()
    }
    
    func start() {
        let searchViewReactor = SearchViewReactor(
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository
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
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
