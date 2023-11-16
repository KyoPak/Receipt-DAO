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
    
    var navigationController: UINavigationController
    var storage: CoreDataStorage
    
    init(navigationController: UINavigationController, storage: CoreDataStorage) {
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let mainViewReactor = MainViewReactor(storage: storage)
        let mainViewController = MainViewController(reactor: mainViewReactor)
        
        mainViewController.coordinator = self
        
        let listViewCoordinator = ListViewCoordinator(navigationController: navigationController, storage: storage)
        childCoordinators.append(listViewCoordinator)
        listViewCoordinator.parentCoordinator = self
        
        navigationController.pushViewController(mainViewController, animated: false)
    }
}
