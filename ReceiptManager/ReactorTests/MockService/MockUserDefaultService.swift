//
//  MockUserDefaultService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import RxSwift
@testable import ReceiptManager

final class MockUserDefaultService: UserDefaultService {
    var event = BehaviorSubject<Int>(value: .zero)
    
    private var currentIndex: Int = .zero
    
    func fetchCurrencyIndex() -> Int {
        return currentIndex
    }
    
    func updateCurrency(index: Int) -> Observable<Int> {
        currentIndex = index
        event.onNext(index)
        return event.asObservable()
    }
}
