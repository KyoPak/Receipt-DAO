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
        let analysisViewReactor = AnalysisViewReactor(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateService: DefaultDateManageService())
        let analysisViewController = AnalysisViewController(reactor: analysisViewReactor)
        
        analysisViewController.coordinator = self
        
        subNavigationController?.pushViewController(analysisViewController, animated: false)
    }
}
