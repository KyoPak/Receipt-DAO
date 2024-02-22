//
//  BookMarkViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class BookMarkViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
    }
    
    func start() {
        let bookMarkViewReactor = BookMarkViewReactor(
            expenseRepository: expenseRepository, 
            userSettingRepository: userSettingRepository
        )
        let bookMarkViewController = BookMarkViewController(reactor: bookMarkViewReactor)
        bookMarkViewController.coordinator = self
        
        subNavigationController?.pushViewController(bookMarkViewController, animated: false)
    }
}

extension BookMarkViewCoordinator {
    func presentDetailView(expense: Receipt) {
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
    
    func presentAlert(error: Error) {
        let alertCoordinator = AlertViewCoordinator(
            mainNavigationController: subNavigationController,
            error: error
        )
        
        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
