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
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    init(
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
    }
    
    func start() {
        let listViewReactor = ListViewReactor(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
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
