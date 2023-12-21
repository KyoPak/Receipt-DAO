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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let userDefaultService: UserDefaultService
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        userDefaultService: UserDefaultService
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor(userDefaultService: userDefaultService)
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        subNavigationController?.pushViewController(settingViewController, animated: false)
    }
}
