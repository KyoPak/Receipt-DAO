//
//  SceneCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift

protocol SceneCoordinator {
    // View 이동
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    
    // View 닫기 혹은 POP
    @discardableResult
    func close(animated: Bool) -> Completable
}
