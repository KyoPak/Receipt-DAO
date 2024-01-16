//
//  DateRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol DateRepository {
    func fetchActiveDate() -> Observable<Date>
    func changeDate(byAddingMonths months: Int) -> Observable<Date>
    func resetToToday() -> Observable<Date>
}

final class DefaultDateRepository: DateRepository {
    private let service: DateManageService

    init(service: DateManageService) {
        self.service = service
    }

    func fetchActiveDate() -> Observable<Date> {
        return service.fetch()
    }

    func changeDate(byAddingMonths months: Int) -> Observable<Date> {
        return service.update(byAddingMonths: months)
    }

    func resetToToday() -> Observable<Date> {
        return service.reset()
    }
}
