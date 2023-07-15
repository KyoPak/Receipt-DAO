//
//  SearchViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/07/02.
//

import RxSwift
import RxCocoa
import RxDataSources

final class SearchViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    private let disposeBag = DisposeBag()
    var searchText = PublishRelay<String?>()
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
        
        return dataSource
    }()
    
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
    
    func cancelAction() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
