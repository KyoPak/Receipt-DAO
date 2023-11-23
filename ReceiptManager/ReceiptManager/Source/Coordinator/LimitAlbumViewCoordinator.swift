//
//  LimitAlbumViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/22.
//

import UIKit

final class LimitAlbumViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    
    init(navigationController: UINavigationController?, storage: CoreDataStorage) {
        self.navigationController = navigationController
        self.storage = storage
    }
    
    func start() {
        let limitAlbumReactor = LimitAlbumViewReactor()
        let limitAlbumViewController = LimitAlbumViewController(reactor: limitAlbumReactor)
        limitAlbumViewController.coordinator = self
        
        limitAlbumViewController.modalPresentationStyle = .fullScreen
        navigationController?.present(limitAlbumViewController, animated: true)
    }
}
