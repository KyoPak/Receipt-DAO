//
//  AlertViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import UIKit

final class AlertViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    var error: Error
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController?,
        error: Error
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
        self.error = error
    }
    
    func start() {
        let alertViewController = CustomAlertViewController(error: error)
        alertViewController.coordinator = self
        alertViewController.modalPresentationStyle = .overFullScreen
        
        subNavigationController?.pushViewController(alertViewController, animated: false)
    }
}
