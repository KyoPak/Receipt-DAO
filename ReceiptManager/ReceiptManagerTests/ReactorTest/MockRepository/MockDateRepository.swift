//
//  MockDateRepository.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 1/17/24.
//

import RxSwift
@testable import ReceiptManager

final class MockDateRepository: DateRepository {
    private let activeDate: BehaviorSubject<Date>
    
    init() {
        activeDate = BehaviorSubject(value: Date())
    }
    
    func fetchActiveDate() -> Observable<Date> {
        return activeDate
    }
    
    func changeDate(byAddingMonths months: Int) -> Observable<Date> {
        let calendar = Calendar.current
        let currentDate = (try? activeDate.value()) ?? Date()
        let updatedDate = calendar.date(byAdding: DateComponents(month: months), to: currentDate) ?? Date()
        
        activeDate.onNext(updatedDate)
        return activeDate
    }
    
    func resetToToday() -> Observable<Date> {
        activeDate.onNext(Date())
        
        return activeDate
    }
}
