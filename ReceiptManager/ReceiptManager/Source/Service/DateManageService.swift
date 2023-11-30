//
//  DateManageService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import RxSwift

protocol DateManageService {
    var currentDateEvent: BehaviorSubject<Date> { get }
    
    func updateDate(byAddingMonths months: Int)
    func updateToday()
}

final class DefaultDateManageService: DateManageService {
    var currentDateEvent: BehaviorSubject<Date>
    
    init() {
        currentDateEvent = BehaviorSubject(value: Date())
    }
    
    func updateDate(byAddingMonths months: Int) {
        let calendar = Calendar.current
        let currentDate = (try? currentDateEvent.value()) ?? Date()
        let updatedDate = calendar.date(byAdding: DateComponents(month: months), to: currentDate) ?? Date()
        
        currentDateEvent.onNext(updatedDate)
    }
    
    func updateToday() {
        currentDateEvent.onNext(Date())
    }
}
