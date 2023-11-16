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
    var navigationController: UINavigationController? { get }
    
    var storage: CoreDataStorage { get }
    
    func start()
    
    func removeChild(_ child: Coordinator?)
    func close(_ controller: UIViewController)
}

extension Coordinator {
    func removeChild(_ child: Coordinator?) {
        guard let child = child,
              let parentCoordinator = parentCoordinator else { return }
        parentCoordinator.childCoordinators.removeAll(where: { $0 === child })
    }
    
    func close(_ controller: UIViewController) {
        var controllers = navigationController?.viewControllers
        if controller.parent == nil {
            controller.dismiss(animated: true)
            return
        }
        
        removeChild(self)
        controllers?.removeAll(where: { $0 === controller })
        
        guard let lastController = controllers?.last else { return }
        navigationController?.popToViewController(lastController, animated: true)
    }
}
