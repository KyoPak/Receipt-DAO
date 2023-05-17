//
//  MainViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/30.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: CommonViewModel {
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .month)
    }
    
    var receiptCountText: Driver<String> {
        return receiptList
            .asDriver(onErrorJustReturn: [])
            .map { receiptSectionModels in
                let dateString = DateFormatter.string(from: Date())
                var countText = ""
                for receiptSectionModel in receiptSectionModels
                where receiptSectionModel.model == dateString {
                    countText = dateString + " 영수증은 \(receiptSectionModel.items.count)건 입니다."
                    break
                }
                
                return countText
            }
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
    
    func moveFavoriteAction() {
        let favoriteViewModel = FavoriteListViewModel(
            title: "즐겨찾기",
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let favoriteScene = Scene.favorite(favoriteViewModel)
        sceneCoordinator.transition(to: favoriteScene, using: .push, animated: true)
    }
}
