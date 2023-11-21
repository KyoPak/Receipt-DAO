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
    
    init(navigationController: UINavigationController?, storage: CoreDataStorage, expense: Receipt) {
        self.navigationController = navigationController
        self.storage = storage
        self.expense = expense
    }
    
    func start() {
        let detailViewReactor = DetailViewReactor(
            title: ConstantText.detail.localize(),
            storage: storage,
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
            navigationController: navigationController,
            storage: storage,
            expense: expense
        )
        childCoordinators.append(composeViewCoordinator)
        composeViewCoordinator.parentCoordinator = self
        
        composeViewCoordinator.startWithPush()
    }
}
