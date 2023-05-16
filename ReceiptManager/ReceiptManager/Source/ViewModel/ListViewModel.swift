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

typealias ReceiptSectionModel = AnimatableSectionModel<String, Receipt>

final class ListViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    private let calendar = Calendar.current
    
    private let currentDateRelay = BehaviorRelay<Date>(value: Date())
    
    var currentDate: Driver<Date> {
        return currentDateRelay.asDriver()
    }
    
    var receiptList: Observable<[ReceiptSectionModel]> {
        return currentDateRelay
            .flatMapLatest { [weak self] currentDate in
                self?.updateReceiptList(for: currentDate) ?? .empty()
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
        
        dataSource.canEditRowAtIndexPath = { _, _ in return true }
        
        return dataSource
    }()
    
    private func updateReceiptList(for currentDate: Date) -> Observable<[ReceiptSectionModel]> {
        return storage.fetch()
            .map { receiptSectionModels in
                return receiptSectionModels.filter { sectionModel in
                    return sectionModel.items.contains { receipt in
                        let receiptDate = DateFormatter.string(from: receipt.receiptDate)
                        return receiptDate == DateFormatter.string(from: currentDate)
                    }
                }
            }
    }
    
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
    
    func moveRegisterAction() {
        let composeViewModel = ComposeViewModel(
            title: "등록하기",
            sceneCoordinator: sceneCoordinator,
            storage: storage
        )
        
        let composeScene = Scene.compose(composeViewModel)
        sceneCoordinator.transition(to: composeScene, using: .push, animated: true)
    }
}
