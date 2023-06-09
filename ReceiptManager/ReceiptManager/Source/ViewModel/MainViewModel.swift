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
    
    private let searchText = PublishRelay<String?>()
    
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
                    countText = dateString + " 영수증은 \(receiptSectionModel.items.count)건 입니다."
                    break
                }
                
                return countText
            }
    }
}

extension MainViewModel {
    func search(_ text: String?) {
        searchText.accept(text)
    }
    
    func moveListAction() {
        let listViewModel = ListViewModel(
            title: ConstantText.list,
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let listScene = Scene.list(listViewModel)
        sceneCoordinator.transition(to: listScene, using: .push, animated: true)
    }
    
    func moveRegisterAction() {
        let composeViewModel = ComposeViewModel(
            title: ConstantText.register,
            sceneCoordinator: sceneCoordinator,
            storage: storage,
            ocrExtractor: OCRTextExtractor()
        )
        
        let composeScene = Scene.compose(composeViewModel)
        sceneCoordinator.transition(to: composeScene, using: .modalNavi, animated: true)
    }
    
    func moveFavoriteAction() {
        let favoriteViewModel = FavoriteListViewModel(
            title: ConstantText.bookMark,
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let favoriteScene = Scene.favorite(favoriteViewModel)
        sceneCoordinator.transition(to: favoriteScene, using: .push, animated: true)
    }
}
