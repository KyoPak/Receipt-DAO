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
    
    var delegate: SelectPickerImageDelegate
    
    init(navigationController: UINavigationController?,
         storage: CoreDataStorage,
         delegate: SelectPickerImageDelegate
    ) {
        self.navigationController = navigationController
        self.storage = storage
        self.delegate = delegate
    }
    
    func start() {
        let limitAlbumReactor = LimitAlbumViewReactor(delegate: delegate)
        let limitAlbumViewController = LimitAlbumViewController(reactor: limitAlbumReactor)
        limitAlbumViewController.coordinator = self
        
        let innerNavigationController = UINavigationController(rootViewController: limitAlbumViewController)
        innerNavigationController.modalPresentationStyle = .fullScreen
        
        navigationController?.present(innerNavigationController, animated: true)
    }
}
