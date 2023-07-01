//
//  SettingViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import Foundation
import RxSwift
import RxDataSources

final class SettingViewModel: CommonViewModel {
    typealias TableViewDataSource = RxTableViewSectionedReloadDataSource<SettingSection>
    
    private let disposeBag = DisposeBag()
    let menuDatas = BehaviorSubject(value: SettingSection.configureSettings())
    
    let dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingCell.identifier,
                for: indexPath
            ) as? SettingCell else {
                return UITableViewCell()
            }
            
            if indexPath.section == .zero {
                cell.showSegment()
            }
            cell.setupData(text: item.title)
            return cell
        }
        
        return dataSource
    }()
    
    func cancelAction() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
