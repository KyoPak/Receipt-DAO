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
    var storageService: StorageService
    var userDefaultService: UserDefaultService
    var expense: Receipt
    
    init(
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        expense: Receipt
    ) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.expense = expense
        
    }
    
    func start() {
        let detailViewReactor = DetailViewReactor(
            title: ConstantText.detail.localize(),
            storageService: storageService,
            userDefaultService: userDefaultService,
            item: expense
        )
        let detailViewController = DetailViewController(reactor: detailViewReactor)
        detailViewController.coordinator = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func presentLargeImage(image: Data) {
        let largeImageViewController = LargeImageViewController(data: image)
        
        navigationController?.present(largeImageViewController, animated: true)
    }
    
    func presentComposeView(expense: Receipt?) {
        let composeViewCoordinator = ComposeViewCoordinator(
            transitionType: .push,
            navigationController: navigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        childCoordinators.append(composeViewCoordinator)
        composeViewCoordinator.parentCoordinator = self
        
        composeViewCoordinator.start()
    }
}
