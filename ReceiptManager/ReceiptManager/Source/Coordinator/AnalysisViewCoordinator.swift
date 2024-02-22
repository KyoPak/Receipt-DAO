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
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
    }
    
    func start() {
        let dateRepository = DefaultDateRepository(service: DefaultDateManageService())
        let analysisViewReactor = AnalysisViewReactor(
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            dateRepository: dateRepository
        )
        let analysisViewController = AnalysisViewController(reactor: analysisViewReactor)
        
        analysisViewController.coordinator = self
        
        subNavigationController?.pushViewController(analysisViewController, animated: false)
    }
}
