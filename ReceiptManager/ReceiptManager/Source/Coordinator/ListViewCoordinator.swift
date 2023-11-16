//
//  ListViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import UIKit

final class ListViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    var storage: CoreDataStorage
    
    init(navigationController: UINavigationController, storage: CoreDataStorage) {
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let listViewReactor = ListViewReactor(storage: storage)
        let listViewController = ListViewController(reactor: listViewReactor)
        
        listViewController.coordinator = self
        
        guard let parentViewController = parentCoordinator?.navigationController.viewControllers.last else {
            return
        }
        parentViewController.addChild(listViewController)
    }
}
