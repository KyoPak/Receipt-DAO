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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    
    init(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.mainNavigationController = mainNavigationController
        self.subNavigationController = subNavigationController
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
        
        subNavigationController?.pushViewController(bookMarkViewController, animated: false)
    }
}

extension BookMarkViewCoordinator {
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            mainNavigationController: mainNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
