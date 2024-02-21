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
    
    private let currencyRepository: CurrencyRepository
    private let paymentTypeRepository: PaymentTypeRepository
    
    private let optionsType: OptionKeyType
    private let options: [String]
    
    init(
        optionType: OptionKeyType,
        options: [String],
        mainNavigationController: UINavigationController?,
        currencyRepository: CurrencyRepository,
        paymentTypeRepository: PaymentTypeRepository
    ) {
        self.optionsType = optionType
        self.options = options
        self.mainNavigationController = mainNavigationController
        self.currencyRepository = currencyRepository
        self.paymentTypeRepository = paymentTypeRepository
        self.subNavigationController = UINavigationController()
    }
    
    func start() {
        let detailSettingReactor = DetailSettingReactor(optionType: optionsType, options: options)
        let detailSettingController = DetailSettingViewController(reactor: detailSettingReactor)
        
        detailSettingController.coordinator = self
        mainNavigationController?.pushViewController(detailSettingController, animated: true)
    }
}
