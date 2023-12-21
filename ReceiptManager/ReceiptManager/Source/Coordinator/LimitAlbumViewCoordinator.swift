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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let delegate: SelectPickerImageDelegate
    private let imageCount: Int
    
    init(navigationController: UINavigationController?,
         delegate: SelectPickerImageDelegate,
         imageCount: Int
    ) {
        self.mainNavigationController = navigationController
        self.delegate = delegate
        self.imageCount = imageCount
    }
    
    func start() {
        let limitAlbumReactor = LimitAlbumViewReactor(delegate: delegate, imageCount: imageCount)
        let limitAlbumViewController = LimitAlbumViewController(reactor: limitAlbumReactor)
        limitAlbumViewController.coordinator = self
        
        let innerNavigationController = UINavigationController(rootViewController: limitAlbumViewController)
        innerNavigationController.modalPresentationStyle = .fullScreen
        
        mainNavigationController?.present(innerNavigationController, animated: true)
    }
}
