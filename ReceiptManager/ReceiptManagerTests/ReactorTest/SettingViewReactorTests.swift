//
//  SettingViewReactorTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 2/22/24.
//

import XCTest
import RxSwift
import RxTest
@testable import ReceiptManager

final class SettingViewReactorTests: XCTestCase {
    private let disposeBag = DisposeBag()
    private var mockUserSettingRepository: UserSettingRepository!
    
    override func setUpWithError() throws {
        mockUserSettingRepository = MockUserSettingRepository()
    }

    override func tearDownWithError() throws {
        mockUserSettingRepository = nil
    }
    
    func test_viewWillAppearAction() {
        // Given
        let reactor = SettingViewReactor()
        let sections = SettingSection.configureSettings()
        
        // When
        reactor.action.onNext(.viewWillAppear)
        
        // Then
        XCTAssertEqual(reactor.currentState.settingMenu.count, sections.count)
    }
    
    func test_cellSelect() {
        // Given
        let reactor = SettingViewReactor()
        let scheduler = TestScheduler(initialClock: .zero)
        let selectIndex = IndexPath(row: 0, section: 0)
        reactor.action.onNext(.viewWillAppear)
        
        // When
        scheduler
            .createHotObservable([
                .next(100, .cellSelect(selectIndex))
            ])
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
        
        reactor.action.onNext(.cellSelect(selectIndex))
        let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            reactor.state.map { $0.selectOptions }
        }
        
        // Then
        XCTAssertEqual(response.events.compactMap { $0.value.element??.0 }, [.currency])
    }
}
