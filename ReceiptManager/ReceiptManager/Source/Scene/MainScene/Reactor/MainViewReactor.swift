//
//  MainViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit
import RxSwift
import RxCocoa

final class MainViewReactor: Reactor {
    enum Action {
        case registerButtonTapped       // 등록 버튼 탭
        case searchButtonTapped         // 검색 버튼 클릭
        case showModeButtomTapped       // 추후 구현 : 캘린더 방식, 리스트 방식
    }
    
    enum Mutation {
        case moveRegister
        case moveSearch
        case changeShowMode
    }
    
    struct State {
        var title: String
        var isRegister: Bool
        var isSearch: Bool
        var showMode: ShowMode
    }
    
    enum ShowMode {
        case calendar
        case list
    }
    
    let initialState = State(
        title: ConstantText.list.localize(), isRegister: false, isSearch: false, showMode: .list
    )

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .registerButtonTapped:
            return .just(.moveRegister)
        case .searchButtonTapped:
            return .just(.moveSearch)
        case .showModeButtomTapped:
            return .just(.changeShowMode)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .moveRegister:
            newState.isRegister = true
        case .moveSearch:
            newState.isSearch = true
        case .changeShowMode:
            newState.showMode = (newState.showMode == .calendar) ? .list : .calendar
        }

        return newState
    }
}
