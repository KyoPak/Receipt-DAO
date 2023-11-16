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
    var window: UIWindow?
    
    init(window: UIWindow?, storage: CoreDataStorage) {
        self.window = window
        self.storage = storage
        self.navigationController = UINavigationController()
    }
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
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
        window?.rootViewController = tabBarController
    }
}
