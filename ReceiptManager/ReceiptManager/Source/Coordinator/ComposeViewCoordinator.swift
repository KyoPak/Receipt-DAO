//
//  ComposeViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import UIKit

enum TransitionType {
    case modal
    case push
}

final class ComposeViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var expense: Receipt?
    var transitionType: TransitionType
    
    init(
        transitionType: TransitionType,
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        expense: Receipt?
    ) {
        self.transitionType = transitionType
        self.navigationController = navigationController
        self.storage = storage
        self.expense = expense
    }
    
    func start() {
        let composeViewReactor = ComposeViewReactor(
            storage: storage,
            expense: expense,
            transisionType: transitionType
        )
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        composeViewController.coordinator = self
        
        switch transitionType {
        case .modal:
            let innerNavigationController = UINavigationController(rootViewController: composeViewController)
            innerNavigationController.modalPresentationStyle = .fullScreen
            navigationController?.present(innerNavigationController, animated: true)
            
        case .push:
            navigationController?.pushViewController(composeViewController, animated: true)
        }
    }
}
