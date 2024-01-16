//
//  DateManageService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import RxSwift

protocol DateManageService {
    func fetch() -> Observable<Date>
    func update(byAddingMonths months: Int) -> Observable<Date>
    func reset() -> Observable<Date>
}

final class DefaultDateManageService: DateManageService {
    private let currentDateEvent: BehaviorSubject<Date>
    
    init() {
        currentDateEvent = BehaviorSubject(value: Date())
    }
    
    func fetch() -> Observable<Date> {
        return currentDateEvent
    }
    
    func update(byAddingMonths months: Int) -> Observable<Date> {
        let calendar = Calendar.current
        let currentDate = (try? currentDateEvent.value()) ?? Date()
        let updatedDate = calendar.date(byAdding: DateComponents(month: months), to: currentDate) ?? Date()
        
        currentDateEvent.onNext(updatedDate)
        return currentDateEvent.asObservable()
    }
    
    func reset() -> Observable<Date> {
        currentDateEvent.onNext(Date())
        return currentDateEvent.asObservable()
    }
}
