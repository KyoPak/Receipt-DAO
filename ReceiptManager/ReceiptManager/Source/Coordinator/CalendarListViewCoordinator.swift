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
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    var dateManageService: DateManageService
    
    private let day: String
    private let weekIndex: Int
    
    init(
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        index: Int
    ) {
        self.navigationController = navigationController
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
        
        self.day = day
        weekIndex = index
    }
    
    func start() {
        let calendarListViewReactor = CalendarListReactor(
            storage: storage,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService,
            day: day
        )
        
        let calendarListViewController = CalendarListViewController(reactor: calendarListViewReactor)
        
        let innerNavigationController = UINavigationController()
        innerNavigationController.setViewControllers([calendarListViewController], animated: true)
        
        innerNavigationController.modalPresentationStyle = .formSheet
        navigationController?.present(innerNavigationController, animated: true)
    }
}
