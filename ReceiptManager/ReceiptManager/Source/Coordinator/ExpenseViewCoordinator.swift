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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
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
            navigationController: mainNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
        
        calendarCoordinator.start()
        
        let child = [
            listViewCoordinator.viewController ?? UIViewController(),
            calendarCoordinator.viewController ?? UIViewController()
        ]
        
        let dateRepository = DefaultDateRepository(service: dateManageService)
        let expenseViewReactor = ExpenseViewReactor(dateRepository: dateRepository)
        let expenseViewController = ExpenseViewController(
            reactor: expenseViewReactor,
            childViewControllers: child
        )
        
        expenseViewController.coordinator = self
        
        childCoordinators.append(listViewCoordinator)
        childCoordinators.append(calendarCoordinator)
        
        listViewCoordinator.parentCoordinator = self
        calendarCoordinator.parentCoordinator = self
        
        subNavigationController?.pushViewController(expenseViewController, animated: false)
    }
}

extension ExpenseViewCoordinator {
    func moveDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            mainNavigationController: mainNavigationController,
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
            mainNavigationController: subNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService
        )
        
        searchViewCoordinator.parentCoordinator = self
        childCoordinators.append(searchViewCoordinator)
        
        searchViewCoordinator.start()
    }
    
    func moveAlertView(error: Error) {
        let alertCoordinator = AlertViewCoordinator(
            mainNavigationController: subNavigationController,
            error: error
        )
        
        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
