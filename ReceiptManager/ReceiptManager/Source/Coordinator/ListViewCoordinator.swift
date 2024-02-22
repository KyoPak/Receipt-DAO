//
//  ListViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import UIKit

final class ListViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    var viewController: UIViewController?
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    private let dateRepository: DateRepository
    
    init(
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository,
        dateRepository: DateRepository
    ) {
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
        self.dateRepository = dateRepository
    }
    
    func start() {
        let listViewReactor = ListViewReactor(
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            dateRepository: dateRepository)
        
        let listViewController = ListViewController(reactor: listViewReactor)
        listViewController.coordinator = self
        viewController = listViewController
        
        guard let parentViewController = parentCoordinator?.mainNavigationController?.viewControllers.last
        else {
            return
        }
        parentViewController.addChild(listViewController)
    }
}

extension ListViewCoordinator {
    func presentDetailView(expense: Receipt) {
        let expenseViewCoordinator = parentCoordinator as? ExpenseViewCoordinator
        
        expenseViewCoordinator?.moveDetailView(expense: expense)
    }
    
    func presentAlert(error: Error) {
        let expenseViewCoordinator = parentCoordinator as? ExpenseViewCoordinator
        
        expenseViewCoordinator?.moveAlertView(error: error)
    }
}
