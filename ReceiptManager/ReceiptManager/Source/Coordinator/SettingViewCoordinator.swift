
//
//  SettingViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/23.
//

import UIKit

final class SettingViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var outerNavigationController: UINavigationController
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storage: CoreDataStorage
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor()
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        navigationController?.pushViewController(settingViewController, animated: false)
    }
}

