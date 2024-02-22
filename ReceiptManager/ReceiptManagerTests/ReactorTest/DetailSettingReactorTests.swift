//
//  DetailSettingReactorTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 2/22/24.
//

import XCTest
import RxSwift
import RxTest
@testable import ReceiptManager

final class DetailSettingReactorTests: XCTestCase {
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
        let options = Currency.allCases.map { $0.description }
        let settingType = SettingType.currency(description: ConstantText.currencySettingDescription, options: options)
        let reactor = DetailSettingReactor(
            userSettingRepository: mockUserSettingRepository,
            optionType: .currency,
            settingType: settingType
        )
        let selectIndex = 2
        
        // When
        reactor.action.onNext(.cellSelect(IndexPath(row: selectIndex, section: 0)))
        let result = mockUserSettingRepository.fetchIndex(type: .currency)
        
        // Then
        XCTAssertEqual(selectIndex, result)
        XCTAssertEqual(selectIndex, reactor.currentState.selectOption)
    }
}
