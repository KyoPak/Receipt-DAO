//
//  ListViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxDataSources

final class ListViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch()
    }
    
    let dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, receipt in
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier, for: indexPath
            ) as? ListTableViewCell else {
                let cell = UITableViewCell()
                return cell
            }
            
            // Cell 셋팅하는 메서드 구현
            dataSource.canEditRowAtIndexPath = { _, _ in return true }
            
            return cell
        }
        
        return dataSource
    }()
}
