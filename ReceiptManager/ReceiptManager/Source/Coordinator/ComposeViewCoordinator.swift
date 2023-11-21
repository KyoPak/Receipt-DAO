//
//  ComposeViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import UIKit

final class ComposeViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var expense: Receipt?
    
    init(navigationController: UINavigationController?, storage: CoreDataStorage, expense: Receipt?) {
        self.navigationController = navigationController
        self.storage = storage
        self.expense = expense
    }
    
    func start() {
        let composeViewReactor = ComposeViewReactor(storage: storage, expense: expense)
        
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        composeViewController.coordinator = self
        
        let innerNavigationController = UINavigationController(rootViewController: composeViewController)
        innerNavigationController.modalPresentationStyle = .fullScreen
        
        navigationController?.present(innerNavigationController, animated: true)
    }
    
    func startWithPush() {
        let composeViewReactor = ComposeViewReactor(storage: storage, expense: expense)
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        
        navigationController?.pushViewController(composeViewController, animated: true)
    }
}
