//
//  MainTabBarCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    var storage: CoreDataStorage
    
    init(navigationController: UINavigationController, storage: CoreDataStorage) {
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let tabBarController = CustomTabBarController()
        tabBarController.coordinator = self
        
        let coordinators = CustomTabItem.allCases.map {
            $0.initialCoordinator(navigationController: navigationController, storage: storage)
        }
        
        coordinators.map {
            $0.start()
            childCoordinators.append($0)
        }
        
        let controllers = coordinators.map { $0.navigationController }
    
        tabBarController.setViewControllers(controllers, animated: false)
    }
}
