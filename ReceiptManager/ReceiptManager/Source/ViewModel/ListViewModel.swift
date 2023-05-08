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
    var receiptList: Observable<[ReceiptSectionModel]> {
        return storage.fetch()
    }
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel> = {
        let dataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel> { dataSource, tableView, indexPath, receipt in
            // 임시 구현
            let cell = tableView.dequeueReusableCell(withIdentifier: "123", for: indexPath)
            
            return cell
        }
        
        return dataSource
    }()
}
