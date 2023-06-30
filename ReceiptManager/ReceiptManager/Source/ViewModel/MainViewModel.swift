//
//  MainViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/30.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

final class MainViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    let searchText = PublishRelay<String?>()
    
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .month)
    }
    
    var searchResultList: Observable<[ReceiptSectionModel]> {
        return Observable.combineLatest(storage.fetch(type: .month), searchText.asObservable())
            .map { receiptSectionModels, text in
                return receiptSectionModels.map { model in
                    let searchItems = model.items.filter { receipt in
                        guard let text = text, text != "" else { return false }
                        return receipt.store.contains(text) ||
                        receipt.product.contains(text) ||
                        receipt.memo.contains(text)
                    }
                    
                    return ReceiptSectionModel(model: model.model, items: searchItems)
                }
                .filter { $0.items.count != .zero }
            }
    }
    
    let dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, receipt in
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier, for: indexPath
            ) as? ListTableViewCell else {
                let cell = UITableViewCell()
                return cell
            }
            
            cell.setupData(data: receipt)
            return cell
        }
        
        return dataSource
    }()
    
    var receiptCountText: Driver<String> {
        return receiptList
            .asDriver(onErrorJustReturn: [])
            .map { receiptSectionModels in
                let dateString = DateFormatter.string(from: Date())
                var countText = ""
                for receiptSectionModel in receiptSectionModels
                where receiptSectionModel.model == dateString {
                    countText = dateString
                    + " "
                    + ConstantText.mainReceiptCount.localized(with: receiptSectionModel.items.count)
                    break
                }
                
                return countText
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
    
    func moveDetailAction(receipt: Receipt) {
        let detailViewModel = DetailViewModel(
            receipt: receipt,
            title: "",
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let detailScene = Scene.detail(detailViewModel)
        sceneCoordinator.transition(to: detailScene, using: .push, animated: true)
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
}
