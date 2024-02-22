//
//  MockUserSettingRepository.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import RxSwift
@testable import ReceiptManager

final class MockUserSettingRepository: UserSettingRepository {
    private var dict: [OptionKeyType: Int] = [.currency: .zero, .payment: .zero, .displayMode: .zero]
    
    var currencyChangeEvent: BehaviorSubject<Int>
    
    init() {
        currencyChangeEvent = BehaviorSubject(value: .zero)
    }
    
    func fetchIndex(type: OptionKeyType) -> Int {
        return dict[type]!
    }
    
    func updateIndex(type: OptionKeyType, index: Int) -> Int {
        if type == .currency { currencyChangeEvent.onNext(index) }
        dict[type] = index
        return dict[type]!
    }
}
