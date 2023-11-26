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
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    var window: UIWindow?
    
    init(window: UIWindow?, storage: CoreDataStorage, userDefaultService: UserDefaultService) {
        self.window = window
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.navigationController = UINavigationController()
    }
    
    func start() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tabBarController = CustomTabBarController()
        tabBarController.coordinator = self
        
        let coordinators = CustomTabItem.allCases.map {
            $0.initialCoordinator(
                outerNavigationController: navigationController ?? UINavigationController(),
                navigationController: UINavigationController(),
                storage: storage,
                userDefaultService: userDefaultService
            )
        }
        
        coordinators.map {
            $0.start()
            $0.parentCoordinator = self
            childCoordinators.append($0)
        }
        
        let controllers = coordinators.map { $0.navigationController ?? UINavigationController() }
        tabBarController.setViewControllers(controllers, animated: false)
        
        navigationController?.setViewControllers([tabBarController], animated: true)
        window?.rootViewController = navigationController
    }
    
    func showRegister() {
        let coordinator = ComposeViewCoordinator(
            transitionType: .modal,
            navigationController: navigationController,
            storage: storage,
            expense: nil
        )
        
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        coordinator.start()
    }
}
