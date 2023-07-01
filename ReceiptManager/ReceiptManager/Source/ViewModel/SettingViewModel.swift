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
    
    func menuSelectAction(menu: SettingOption) {
        switch menu.title {
        case ConstantText.opinion.localize():
            let emailURL = createEmailUrl(
                subject: ConstantText.mailSubject.localize(),
                body: ConstantText.mailBody.localize()
            )
            openURL(urlString: emailURL)
        case ConstantText.rating.localize():
            let appStoreURL = createAppStoreURL()
            openURL(urlString: appStoreURL)
        case ConstantText.dataClear.localize():
            print("Clear Data")
        default:
            return
        }
    }
    
    private func openURL(urlString: String) {
        if let url = URL(string: "\(urlString)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func createAppStoreURL() -> String {
        let url = "itms-apps://itunes.apple.com/app/" + ConstantText.appID
        return url
    }
    
    private func createEmailUrl(subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
        let defaultUrl = "mailto:\(ConstantText.myEmail)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
            
        return defaultUrl
    }
}
