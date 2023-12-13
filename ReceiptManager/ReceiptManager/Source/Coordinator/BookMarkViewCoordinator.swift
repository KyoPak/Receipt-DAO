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
    var storageService: StorageService
    var userDefaultService: UserDefaultService
    
    init(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.outerNavigationController = outerNavigationController
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let bookMarkViewReactor = BookMarkViewReactor(
            storageService: storageService,
            userDefaultService: userDefaultService
        )
        let bookMarkViewController = BookMarkViewController(reactor: bookMarkViewReactor)
        bookMarkViewController.coordinator = self
        
        navigationController?.pushViewController(bookMarkViewController, animated: false)
    }
    
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: outerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
