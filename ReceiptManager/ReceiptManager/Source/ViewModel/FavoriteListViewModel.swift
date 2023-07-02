//
//  FavoriteListViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

final class FavoriteListViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    private let disposeBag = DisposeBag()

    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .month).map { receiptSectionModels in
            return receiptSectionModels.map { model in
                let filteredItems = model.items.filter { $0.isFavorite }
                return ReceiptSectionModel(model: model.model, items: filteredItems)
            }
            .filter { !$0.items.isEmpty }
        }
    }
    
    let dataSource: TableViewDataSource = {
        let currencyIndex = UserDefaults.standard.integer(forKey: ConstantText.currencyKey)
        
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, receipt in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier, for: indexPath
            ) as? ListTableViewCell else {
                let cell = UITableViewCell()
                return cell
            }
            
            cell.setupData(data: receipt, currencyIndex: currencyIndex)
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _, _ in return true }
        
        return dataSource
    }()
    
    func favoriteAction(indexPath: IndexPath) {
        receiptList
            .take(1)
            .map { $0[indexPath.section].items }
            .subscribe(onNext: { [weak self] items in
                var receipt = items[indexPath.row]
                receipt.isFavorite.toggle()
                self?.storage.upsert(receipt: receipt)
            })
            .disposed(by: disposeBag)
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
}
