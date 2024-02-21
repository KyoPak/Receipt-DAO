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
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    private let dateRepository: DateRepository
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository,
        dateRepository: DateRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
        self.dateRepository = dateRepository
    }
    
    func start() {
        let listViewCoordinator = ListViewCoordinator(
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            dateRepository: dateRepository
        )
        
        listViewCoordinator.start()
        
        let calendarCoordinator = CalendarViewCoordinator(
            navigationController: mainNavigationController,
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            dateRepository: dateRepository
        )
        
        calendarCoordinator.start()
        
        let child = [
            listViewCoordinator.viewController ?? UIViewController(),
            calendarCoordinator.viewController ?? UIViewController()
        ]
        
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
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
    
    func moveSearchView() {
        let searchViewCoordinator = SearchViewCoordinator(
            mainNavigationController: subNavigationController,
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository
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
