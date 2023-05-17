//
//  DefaultSceneCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Extension UIViewController
// 실제로 보여지는 ViewController
extension UIViewController {
    var sceneViewController: UIViewController {
        return children.last ?? self
    }
}

final class DefaultSceneCoordinator: SceneCoordinator {
    private let disposeBag = DisposeBag()
    
    private var window: UIWindow
    private var currentViewController: UIViewController = UIViewController()
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        let subject = PublishSubject<Never>()
        let moveTarget = scene.instantiate()
        
        switch style {
        case .root:
            currentViewController = moveTarget.sceneViewController
            window.rootViewController = UINavigationController(rootViewController: currentViewController)
            window.makeKeyAndVisible()
            
            subject.onCompleted()
        case .push:
            guard let navigation = currentViewController.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            navigation.rx.willShow
                .withUnretained(self)
                .subscribe(onNext: { coordinator, event in
                    coordinator.currentViewController = event.viewController.sceneViewController
                })
                .disposed(by: disposeBag)
            
            navigation.pushViewController(moveTarget, animated: true)
            currentViewController = moveTarget.sceneViewController
            
            subject.onCompleted()
        case .modal:
            let navigation = UINavigationController(rootViewController: moveTarget)
            navigation.modalPresentationStyle = .fullScreen
            
            currentViewController.present(navigation, animated: animated) {
                subject.onCompleted()
            }
            
            currentViewController = navigation.sceneViewController
        }
        
        return subject.asCompletable()
    }
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        
        return Completable.create { [weak self] completable in
            
            // Modal 방식 인 경우
            if let presentingViewController = self?.currentViewController.presentingViewController {
                self?.currentViewController.dismiss(animated: animated) {
                    self?.currentViewController = presentingViewController.sceneViewController
                    completable(.completed)
                }
                // Push 방식 인 경우
            } else if let navigation = self?.currentViewController.navigationController {
                guard navigation.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                
                self?.currentViewController = navigation.viewControllers.last!.sceneViewController
                completable(.completed)
            } else {
                completable(.error(TransitionError.unknown))
            }
            
            return Disposables.create()
        }
    }
}
