//
//  DateManageService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import RxSwift

protocol DateManageService {
    var currentDateEvent: BehaviorSubject<Date> { get }
    func fetchDate() -> Observable<Date>
    func updateDate(byAddingMonths months: Int) -> Observable<Date>
    func updateToday() -> Observable<Date>
}

final class DefaultDateManageService: DateManageService {
    var currentDateEvent: BehaviorSubject<Date>
    
    init() {
        currentDateEvent = BehaviorSubject(value: Date())
    }
    
    func fetchDate() -> Observable<Date> {
        return currentDateEvent.asObservable()
    }
    
    func updateDate(byAddingMonths months: Int) -> Observable<Date> {
        let calendar = Calendar.current
        let currentDate = (try? currentDateEvent.value()) ?? Date()
        let updatedDate = calendar.date(byAdding: DateComponents(month: months), to: currentDate) ?? Date()
        
        currentDateEvent.onNext(updatedDate)
        return currentDateEvent.asObservable()
    }
    
    func updateToday() -> Observable<Date> {
        currentDateEvent.onNext(Date())
        return currentDateEvent.asObservable()
    }
}
