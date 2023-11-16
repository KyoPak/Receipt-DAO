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
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var viewController: UIViewController?
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func start() {
        let listViewReactor = ListViewReactor(storage: storage)
        let listViewController = ListViewController(reactor: listViewReactor)
        listViewController.coordinator = self
        viewController = listViewController
        
        guard let parentViewController = parentCoordinator?.navigationController?.viewControllers.last else {
            return
        }
        parentViewController.addChild(listViewController)
    }
    
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: UINavigationController(),
            storage: storage,
            expense: expense
        )
        
        childCoordinators.append(detailViewCoordinator)
        detailViewCoordinator.parentCoordinator = self
        detailViewCoordinator.start()
    }
}
