//
//  Coordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    var storage: CoreDataStorage { get }
    
    func start()
    
    func removeChild(to child: Coordinator?)
    func close(to controller: UIViewController)
}
