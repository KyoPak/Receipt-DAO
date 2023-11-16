//
//  BookMarkViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class BookMarkViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    var storage: CoreDataStorage
    
    init(navigationController: UINavigationController, storage: CoreDataStorage) {
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let bookMarkViewReactor = BookMarkViewReactor(storage: storage)
        let bookMarkViewController = BookMarkViewController(reactor: bookMarkViewReactor)
        
        bookMarkViewController.coordinator = self
        
        navigationController.pushViewController(bookMarkViewController, animated: false)
    }
}
