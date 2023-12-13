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
    var storageService: StorageService
    var userDefaultService: UserDefaultService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor(userDefaultService: userDefaultService)
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        navigationController?.pushViewController(settingViewController, animated: false)
    }
}
