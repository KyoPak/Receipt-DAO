//
//  MainViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/30.
//

import RxDataSources
import RxSwift
import RxCocoa

final class MainViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .month)
    }
        
    var receiptCountText: Driver<String> {
        return receiptList
            .asDriver(onErrorJustReturn: [])
            .map { receiptSectionModels in
                let dateString = DateFormatter.string(from: Date())
                
                var registerCount = 0
                for receiptModel in receiptSectionModels where receiptModel.model == dateString {
                    registerCount = receiptModel.items.count
                    break
                }
                
                return dateString + " " + ConstantText.mainReceiptCount.localized(with: registerCount)
            }
    }
}

extension MainViewModel {
    func moveListAction() {
        let listViewModel = ListViewModel(
            title: ConstantText.list.localize(),
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let listScene = Scene.list(listViewModel)
        sceneCoordinator.transition(to: listScene, using: .push, animated: true)
    }
    
    func moveRegisterAction() {
        let composeViewModel = ComposeViewModel(
            title: ConstantText.register.localize(),
            sceneCoordinator: sceneCoordinator,
            storage: storage,
            ocrExtractor: OCRTextExtractor()
        )
        
        let composeScene = Scene.compose(composeViewModel)
        sceneCoordinator.transition(to: composeScene, using: .modalNavi, animated: true)
    }
    
    func moveFavoriteAction() {
        let favoriteViewModel = FavoriteListViewModel(
            title: ConstantText.bookMark.localize(),
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let favoriteScene = Scene.favorite(favoriteViewModel)
        sceneCoordinator.transition(to: favoriteScene, using: .push, animated: true)
    }
    
    func moveSettingAction() {
        let settingViewModel = SettingViewModel(
            title: ConstantText.setting.localize(),
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let settingScene = Scene.setting(settingViewModel)
        sceneCoordinator.transition(to: settingScene, using: .modalNavi, animated: true)
    }
    
    func moveSearchAction() {
        let searchViewModel = SearchViewModel(title: "", sceneCoordinator: sceneCoordinator, storage: storage)
        
        let searchScene = Scene.search(searchViewModel)
        sceneCoordinator.transition(to: searchScene, using: .modalNavi, animated: false)
    }
}
