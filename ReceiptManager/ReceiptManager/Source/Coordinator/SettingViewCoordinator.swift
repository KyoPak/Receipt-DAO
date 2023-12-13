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
    
    private let userDefaultService: UserDefaultService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        userDefaultService: UserDefaultService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor(userDefaultService: userDefaultService)
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        navigationController?.pushViewController(settingViewController, animated: false)
    }
}
