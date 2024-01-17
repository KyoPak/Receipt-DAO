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
    
    weak var retryDelegate: Retriable?
    var error: Error
    
    init(mainNavigationController: UINavigationController?, error: Error, retryDelegate: Retriable? = nil) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = UINavigationController()
        self.error = error
        self.retryDelegate = retryDelegate
    }
    
    func start() {
        let alertViewController = CustomAlertViewController(error: error, delegate: retryDelegate)
        alertViewController.coordinator = self
        
        subNavigationController?.modalPresentationStyle = .overFullScreen
        subNavigationController?.setViewControllers([alertViewController], animated: true)
        mainNavigationController?.present(
            subNavigationController ?? UINavigationController(),
            animated: false
        )
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        controller.dismiss(animated: false)
    }
}
