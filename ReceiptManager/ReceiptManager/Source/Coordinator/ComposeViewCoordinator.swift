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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    
    private let expense: Receipt?
    private let transitionType: TransitionType
    
    init(
        transitionType: TransitionType,
        mainNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        expense: Receipt?
    ) {
        self.transitionType = transitionType
        self.mainNavigationController = mainNavigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.expense = expense
        self.subNavigationController = UINavigationController()
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
            subNavigationController?.setViewControllers([composeViewController], animated: true)
            subNavigationController?.modalPresentationStyle = .fullScreen
            mainNavigationController?.present(subNavigationController ?? UINavigationController(), animated: true)
            
        case .push:
            mainNavigationController?.pushViewController(composeViewController, animated: true)
        }
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        
        switch transitionType {
        case .modal:
            controller.navigationController?.dismiss(animated: true)
        
        case .push:
            mainNavigationController?.popViewController(animated: true)
        }
    }
}

extension ComposeViewCoordinator {
    func presentLimitAlbumView(delegate: SelectPickerImageDelegate, imageCount: Int) {
        let limitAlbumViewCoordinator: LimitAlbumViewCoordinator
        
        switch transitionType {
        case .modal:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: subNavigationController,
                delegate: delegate,
                imageCount: imageCount
            )
        case .push:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: mainNavigationController,
                delegate: delegate,
                imageCount: imageCount
            )
        }
        
        limitAlbumViewCoordinator.parentCoordinator = self
        childCoordinators.append(limitAlbumViewCoordinator)
        
        limitAlbumViewCoordinator.start()
    }
}
