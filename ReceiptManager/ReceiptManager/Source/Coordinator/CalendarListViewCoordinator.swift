//
//  CalendarListViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

final class CalendarListViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var innerNavigationController: UINavigationController
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    private let day: String
    private let weekIndex: Int
    
    init(
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        index: Int
    ) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
        
        self.day = day
        weekIndex = index
        innerNavigationController = UINavigationController()
    }
    
    func start() {
        let calendarListViewReactor = CalendarListReactor(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService,
            day: day,
            weekIndex: weekIndex
        )
        
        let calendarListViewController = CalendarListViewController(reactor: calendarListViewReactor)
        calendarListViewController.coordinator = self
        
        let bottomSheetViewController = BottomSheetViewController(
            controller: calendarListViewController,
            bottomHeightRatio: 0.7
        )
        
        innerNavigationController.setViewControllers([bottomSheetViewController], animated: true)
        
        innerNavigationController.modalPresentationStyle = .overFullScreen
        
        navigationController?.present(innerNavigationController, animated: true)
    }
    
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: innerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
}
