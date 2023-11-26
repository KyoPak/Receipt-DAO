//
//  MainViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class MainViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var outerNavigationController: UINavigationController
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storage = storage
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let listViewCoordinator = ListViewCoordinator(
            storage: storage, 
            userDefaultService: userDefaultService
        )
        listViewCoordinator.start()
        
        let child = [listViewCoordinator.viewController ?? UIViewController()]
        
        let mainViewReactor = MainViewReactor(storage: storage)
        let mainViewController = MainViewController(reactor: mainViewReactor, childViewControllers: child)
        
        mainViewController.coordinator = self
        
        childCoordinators.append(listViewCoordinator)
        listViewCoordinator.parentCoordinator = self
        
        navigationController?.pushViewController(mainViewController, animated: false)
    }
    
    func moveDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: outerNavigationController,
            storage: storage,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
