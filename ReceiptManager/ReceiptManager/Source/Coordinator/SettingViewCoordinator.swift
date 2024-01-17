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
    
    private let currencyRepository: CurrencyRepository
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        currencyRepository: CurrencyRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.currencyRepository = currencyRepository
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor(currencyRepository: currencyRepository)
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        subNavigationController?.pushViewController(settingViewController, animated: false)
    }
}
