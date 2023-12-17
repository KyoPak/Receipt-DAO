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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    
    private let expense: Receipt
    
    init(
        mainNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        expense: Receipt
    ) {
        self.mainNavigationController = mainNavigationController
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
        mainNavigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension DetailViewCoordinator {
    func presentLargeImage(image: Data) {
        let largeImageViewController = LargeImageViewController(data: image)
        
        mainNavigationController?.present(largeImageViewController, animated: true)
    }
    
    func presentComposeView(expense: Receipt?) {
        let composeViewCoordinator = ComposeViewCoordinator(
            transitionType: .push,
            mainNavigationController: mainNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        childCoordinators.append(composeViewCoordinator)
        composeViewCoordinator.parentCoordinator = self
        
        composeViewCoordinator.start()
    }
}
