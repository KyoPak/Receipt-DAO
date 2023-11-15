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
        
        let mainViewReactor = MainViewReactor(stoage: storage)
        let mainNavigationController = UINavigationController(
            rootViewController: MainViewController(reactor: mainViewReactor)
        )
        
        tabBarController.setViewControllers([mainNavigationController], animated: false)
    }
    
    func removeChild(to child: Coordinator?) { }
    
    func close(to controller: UIViewController) { }
}
