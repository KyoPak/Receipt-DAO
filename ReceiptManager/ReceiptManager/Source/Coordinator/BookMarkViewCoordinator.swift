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
        let bookMarkViewReactor = BookMarkViewReactor(storage: storage, userDefaultService: userDefaultService)
        let bookMarkViewController = BookMarkViewController(reactor: bookMarkViewReactor)
        
        bookMarkViewController.coordinator = self
        
        navigationController?.pushViewController(bookMarkViewController, animated: false)
    }
    
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: outerNavigationController,
            storage: storage,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
