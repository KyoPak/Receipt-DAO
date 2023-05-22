//
//  SelectImageViewModel.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/22.
//

import Foundation
import RxCocoa
import RxSwift

protocol SelectCompletable: AnyObject {
    func selectComplete(datas: [Data])
}

final class SelectImageViewModel: CommonViewModel {
    private let disposeBag = DisposeBag()
    // 선택 목록 이미지 데이터
    var selectData = BehaviorSubject<[Data]>(value: [])
    
    // 선택한 이미지 데이터
    var addData = BehaviorSubject<[Data]>(value: [])
    var selectMaxCount: Int
    
    weak var pickerDelegate: SelectPickerDelegate?
    weak var selectCompleteDelegate: SelectCompletable?
    
    init(
        title: String,
        sceneCoordinator: SceneCoordinator,
        storage: ReceiptStorage,
        data: [Data] = [],
        count: Int,
        pickerDelegate: SelectPickerDelegate,
        selectCompleteDelegate: SelectCompletable
    ) {
        self.selectData = BehaviorSubject(value: data)
        self.pickerDelegate = pickerDelegate
        self.selectCompleteDelegate = selectCompleteDelegate
        selectMaxCount = count
        
        super.init(title: title, sceneCoordinator: sceneCoordinator, storage: storage)
    }
    
    func closeView() {
        sceneCoordinator.close(animated: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func add(data: Data?) {
        guard let data = data else { return }
        var addDatas = (try? addData.value()) ?? []
        addDatas.append(data)
        
        addData.onNext(addDatas)
    }
    
    func remove(data: Data?) {
        guard let data = data else { return }
        
        var addDatas = (try? addData.value()) ?? []
        if addDatas.contains(data) {
            let index = addDatas.firstIndex(of: data) ?? .zero
            addDatas.remove(at: index)
        }
        
        addData.onNext(addDatas)
    }
    
    func selectComplete() {
        let datas = (try? addData.value()) ?? []
        selectCompleteDelegate?.selectComplete(datas: datas)
        
        closeView()
    }
}
