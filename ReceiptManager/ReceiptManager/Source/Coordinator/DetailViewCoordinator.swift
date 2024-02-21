//
//  DetailViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import UIKit

final class DetailViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    
    private let expense: Receipt
    
    init(
        mainNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository,
        expense: Receipt
    ) {
        self.mainNavigationController = mainNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
        self.expense = expense
    }
    
    func start() {
        let detailViewReactor = DetailViewReactor(
            title: ConstantText.detail.localize(),
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            item: expense
        )
        let detailViewController = DetailViewController(reactor: detailViewReactor)
        detailViewController.coordinator = self
        mainNavigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension DetailViewCoordinator {
    func presentLargeImage(image: Data) {
        let largeImageViewController = LargeImageViewController(data: image)
        
        mainNavigationController?.present(largeImageViewController, animated: true)
    }
    
    func presentComposeView(expense: Receipt?) {
        let composeViewCoordinator = ComposeViewCoordinator(
            transitionType: .push,
            mainNavigationController: mainNavigationController,
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            expense: expense
        )
        childCoordinators.append(composeViewCoordinator)
        composeViewCoordinator.parentCoordinator = self
        
        composeViewCoordinator.start()
    }
    
    func presentAlert(error: Error) {
        let alertCoordinator = AlertViewCoordinator(
            mainNavigationController: mainNavigationController,
            error: error
        )
        
        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
