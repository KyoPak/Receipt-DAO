//
//  MainViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/30.
//

import Foundation
import RxSwift

final class MainViewModel: CommonViewModel {
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch()
    }
    
    func moveListAction() {
        let listViewModel = ListViewModel(
            title: "내 영수증",
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let listScene = Scene.list(listViewModel)
        sceneCoordinator.transition(to: listScene, using: .push, animated: true)
    }
    
    func moveRegisterAction() {
        let composeViewModel = ComposeViewModel(
            title: "등록하기",
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let composeScene = Scene.compose(composeViewModel)
        sceneCoordinator.transition(to: composeScene, using: .modal, animated: true)
    }
}
