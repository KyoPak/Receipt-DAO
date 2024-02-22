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
    
    private let userSettingRepository: UserSettingRepository
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        userSettingRepository: UserSettingRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.userSettingRepository = userSettingRepository
    }
    
    func start() {
        let settingViewReactor = SettingViewReactor()
        let settingViewController = SettingViewController(reactor: settingViewReactor)
        
        settingViewController.coordinator = self
        
        subNavigationController?.pushViewController(settingViewController, animated: false)
    }
    
    func presentDetailOption(optionType: OptionKeyType, settingType: SettingType) {
        let detailSettingCoordinator = DetailSettingCoordinator(
            optionType: optionType,
            settingType: settingType,
            mainNavigationController: mainNavigationController,
            userSettingRepository: userSettingRepository
        )
        
        detailSettingCoordinator.parentCoordinator = self
        childCoordinators.append(detailSettingCoordinator)
        detailSettingCoordinator.start()
    }
}
