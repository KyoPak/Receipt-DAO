//
//  DetailSettingCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import UIKit

final class DetailSettingCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let userSettingRepository: UserSettingRepository
    
    private let optionsType: OptionKeyType
    private let settingType: SettingType
    
    init(
        optionType: OptionKeyType,
        settingType: SettingType,
        mainNavigationController: UINavigationController?,
        userSettingRepository: UserSettingRepository
    ) {
        self.optionsType = optionType
        self.settingType = settingType
        self.mainNavigationController = mainNavigationController
        self.userSettingRepository = userSettingRepository
        self.subNavigationController = UINavigationController()
    }
    
    func start() {
        let detailSettingReactor = DetailSettingReactor(
            userSettingRepository: userSettingRepository,
            optionType: optionsType,
            settingType: settingType
        )
        let detailSettingController = DetailSettingViewController(reactor: detailSettingReactor)
        
        detailSettingController.coordinator = self
        mainNavigationController?.pushViewController(detailSettingController, animated: true)
    }
}
