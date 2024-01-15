//
//  AnalysisViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/7/23.
//

import UIKit

final class AnalysisViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let expenseRepository = DefaultExpenseRepository(service: storageService)
        let currencyRepository = DefaultCurrencyRepository(service: userDefaultService)
        let dateRepository = DefaultDateRepository(service: DefaultDateManageService())
        let analysisViewReactor = AnalysisViewReactor(
            expenseRepository: expenseRepository,
            currencyRepository: currencyRepository,
            dateRepository: dateRepository
        )
        let analysisViewController = AnalysisViewController(reactor: analysisViewReactor)
        
        analysisViewController.coordinator = self
        
        subNavigationController?.pushViewController(analysisViewController, animated: false)
    }
}
