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
    
    var outerNavigationController: UINavigationController
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storage = storage
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let analysisViewReactor = AnalysisViewReactor()
        let analysisViewController = AnalysisViewController(reactor: analysisViewReactor)
        
        analysisViewController.coordinator = self
        
        navigationController?.pushViewController(analysisViewController, animated: false)
    }
}
