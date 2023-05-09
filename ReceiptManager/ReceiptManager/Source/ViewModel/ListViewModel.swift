//
//  ListViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

extension DateFormatter {
    static let standard = DateFormatter()
    
    static func string(from date: Date, format: String) -> String {
        standard.dateFormat = format
        return standard.string(from: date)
    }
}

final class ListViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    private let calendar = Calendar.current
    
    private let currentDateRelay = BehaviorRelay<Date>(value: Date())
    var currentDate: Driver<Date> {
        return currentDateRelay.asDriver()
    }
    
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
            
            cell.setupData(data: receipt)
            dataSource.canEditRowAtIndexPath = { _, _ in return true }
            
            return cell
        }
        
        return dataSource
    }()
    
    func movePriviousAction() {
        let previousDate = calendar
            .date(byAdding: DateComponents(month: -1), to: currentDateRelay.value) ?? Date()
        currentDateRelay.accept(previousDate)
    }
    
    func moveNextAction() {
        let nextDate = calendar
            .date(byAdding: DateComponents(month: 1), to: currentDateRelay.value) ?? Date()
        currentDateRelay.accept(nextDate)
    }
    
    func moveNowAction() {
        let nowDate = Date()
        currentDateRelay.accept(nowDate)
    }
}
