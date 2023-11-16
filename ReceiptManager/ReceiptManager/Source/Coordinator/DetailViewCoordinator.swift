//
//  DetailViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import UIKit

final class DetailViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var expense: Receipt
    
    init(navigationController: UINavigationController, storage: CoreDataStorage, expense: Receipt) {
        self.navigationController = navigationController
        self.storage = storage
        self.expense = expense
    }
    
    func start() {
        let detailViewReactor = DetailViewReactor(storage: storage, item: expense)
        let detailViewController = DetailViewController(reactor: detailViewReactor)
        detailViewController.coordinator = self
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
