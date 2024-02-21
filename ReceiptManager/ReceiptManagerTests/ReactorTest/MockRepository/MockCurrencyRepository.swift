//
//  MockCurrencyRepository.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import RxSwift
@testable import ReceiptManager

final class MockCurrencyRepository: UserSettingRepository {
    var saveEvent: BehaviorSubject<Int>
    
    init() {
        saveEvent = BehaviorSubject(value: .zero)
    }
    
    func fetchCurrencyIndex() -> Int {
        return (try? saveEvent.value()) ?? .zero
    }
    
    func updateCurrency(index: Int) -> Observable<Int> {
        saveEvent.onNext(index)
        return saveEvent
    }
}
