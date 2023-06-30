//
//  SettingViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import Foundation
import RxSwift

final class SettingViewModel: CommonViewModel {
    private let disposeBag = DisposeBag()
    
    func cancelAction() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
