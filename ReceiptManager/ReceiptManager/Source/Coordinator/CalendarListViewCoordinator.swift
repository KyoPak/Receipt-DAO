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
    
    var viewController: UIViewController?
    
    init(
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
    }
    
    func start() {
        
    }
    
    func presentDetailView(expense: Receipt) {
        
    }
}
