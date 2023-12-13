//
//  ComposeViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import UIKit

enum TransitionType {
    case modal
    case push
}

final class ComposeViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var innerNavigationController: UINavigationController
    var storageService: StorageService
    var userDefaultService: UserDefaultService
    var expense: Receipt?
    var transitionType: TransitionType
    
    init(
        transitionType: TransitionType,
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        expense: Receipt?
    ) {
        self.transitionType = transitionType
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.expense = expense
        self.innerNavigationController = UINavigationController()
    }
    
    func start() {
        let ocrExtractor = DefaultOCRExtractorService(currencyIndex: try? userDefaultService.event.value())
        
        let composeViewReactor = ComposeViewReactor(
            storageService: storageService,
            ocrExtractor: ocrExtractor,
            expense: expense,
            transisionType: transitionType
        )
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        composeViewController.coordinator = self
        
        switch transitionType {
        case .modal:
            innerNavigationController.setViewControllers([composeViewController], animated: true)
            innerNavigationController.modalPresentationStyle = .fullScreen
            navigationController?.present(innerNavigationController, animated: true)
            
        case .push:
            navigationController?.pushViewController(composeViewController, animated: true)
        }
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        
        switch transitionType {
        case .modal:
            controller.navigationController?.dismiss(animated: true)
        
        case .push:
            navigationController?.popViewController(animated: true)
        }
    }
    
    func presentLimitAlbumView(delegate: SelectPickerImageDelegate, imageCount: Int) {
        let limitAlbumViewCoordinator: LimitAlbumViewCoordinator
        
        switch transitionType {
        case .modal:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: innerNavigationController,
                storageService: storageService,
                delegate: delegate,
                imageCount: imageCount
            )
        case .push:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: navigationController,
                storageService: storageService,
                delegate: delegate,
                imageCount: imageCount
            )
        }
        
        limitAlbumViewCoordinator.parentCoordinator = self
        childCoordinators.append(limitAlbumViewCoordinator)
        
        limitAlbumViewCoordinator.start()
    }
}
