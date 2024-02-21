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
    
    func presentDetailOption(optionType: OptionKeyType, datas: [String]) {
        // TODO: - Fix
        let paymentTypeRepository = DefaultPaymentTypeRepository(service: DefaultUserDefaultService())
        let detailSettingCoordinator = DetailSettingCoordinator(
            optionType: optionType,
            options: datas,
            mainNavigationController: mainNavigationController, 
            currencyRepository: currencyRepository,
            paymentTypeRepository: paymentTypeRepository
        )
        
        detailSettingCoordinator.parentCoordinator = self
        childCoordinators.append(detailSettingCoordinator)
        detailSettingCoordinator.start()
    }
}
