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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let expenseRepository: ExpenseRepository
    private let currencyRepository: CurrencyRepository
    private let dateRepository: DateRepository
    
    private let day: String
    private let weekIndex: Int
    
    init(
        mainNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        currencyRepository: CurrencyRepository,
        dateRepository: DateRepository,
        day: String,
        index: Int
    ) {
        self.mainNavigationController = mainNavigationController
        self.expenseRepository = expenseRepository
        self.currencyRepository = currencyRepository
        self.dateRepository = dateRepository
        
        self.day = day
        weekIndex = index
        subNavigationController = UINavigationController()
    }
    
    func start() {
        let calendarListViewReactor = CalendarListReactor(
            expenseRepository: expenseRepository,
            dateRepository: dateRepository,
            currencyRepository: currencyRepository,
            day: day,
            weekIndex: weekIndex
        )
        
        let calendarListViewController = CalendarListViewController(reactor: calendarListViewReactor)
        calendarListViewController.coordinator = self
        
        let bottomSheetViewController = BottomSheetViewController(
            controller: calendarListViewController,
            bottomHeightRatio: 0.7,
            delegate: calendarListViewController
        )
        
        subNavigationController?.setViewControllers([bottomSheetViewController], animated: true)
        subNavigationController?.modalPresentationStyle = .overFullScreen
        
        mainNavigationController?.present(subNavigationController ?? UINavigationController(), animated: true)
    }
}

extension CalendarListViewCoordinator {
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            mainNavigationController: subNavigationController,
            expenseRepository: expenseRepository,
            currencyRepository: currencyRepository,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
    
    func presentAlert(error: Error) {
        let alertCoordinator = AlertViewCoordinator(
            mainNavigationController: subNavigationController,
            error: error
        )
        
        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
