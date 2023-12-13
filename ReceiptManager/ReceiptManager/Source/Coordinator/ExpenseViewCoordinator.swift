//
//  ExpenseViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class ExpenseViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var outerNavigationController: UINavigationController
    var navigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
    }
    
    func start() {
        let listViewCoordinator = ListViewCoordinator(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
        
        listViewCoordinator.start()
        
        let calendarCoordinator = CalendarViewCoordinator(
            navigationController: outerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
        
        calendarCoordinator.start()
        
        let child = [
            listViewCoordinator.viewController ?? UIViewController(),
            calendarCoordinator.viewController ?? UIViewController()
        ]
        
        let expenseViewReactor = ExpenseViewReactor(dateService: dateManageService)
        let expenseViewController = ExpenseViewController(
            reactor: expenseViewReactor,
            childViewControllers: child
        )
        
        expenseViewController.coordinator = self
        
        childCoordinators.append(listViewCoordinator)
        childCoordinators.append(calendarCoordinator)
        
        listViewCoordinator.parentCoordinator = self
        calendarCoordinator.parentCoordinator = self
        
        navigationController?.pushViewController(expenseViewController, animated: false)
    }
    
    func moveDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: outerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
    
    func moveSearchView() {
        let searchViewCoordinator = SearchViewCoordinator(
            navigationController: outerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService
        )
        
        searchViewCoordinator.parentCoordinator = self
        childCoordinators.append(searchViewCoordinator)
        
        searchViewCoordinator.start()
    }
}
