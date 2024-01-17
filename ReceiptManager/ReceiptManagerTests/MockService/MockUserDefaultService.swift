//
//  MockUserDefaultService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import RxSwift
@testable import ReceiptManager

final class MockUserDefaultService: UserDefaultService {
    private var currentData: Int = .zero
    
    func fetch() -> Int {
        return currentData
    }
    
    func update(index: Int) -> Observable<Int> {
        currentData = index
        return Observable.just(currentData)
    }
}
