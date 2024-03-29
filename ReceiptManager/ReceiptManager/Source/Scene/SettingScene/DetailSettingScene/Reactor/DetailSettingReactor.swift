//
//  DetailSettingReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import ReactorKit

final class DetailSettingReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case cellSelect(IndexPath)
    }
    
    enum Mutation {
        case settingChange(Int)
    }
    
    struct State {
        var title: String
        var optionType: OptionKeyType
        var detailOptions: [String]
        var detailOptionDescription: String
        var selectOption: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let userSettingRepository: UserSettingRepository
    
    // Initializer
    
    init(userSettingRepository: UserSettingRepository, optionType: OptionKeyType, settingType: SettingType) {
        self.userSettingRepository = userSettingRepository
        
        var optionDescription: String
        var optionList: [String]
        
        switch settingType {
        case .currency(let description, let options), 
             .payment(let description, let options),
             .displayMode(let description, let options):
            optionDescription = description
            optionList = options
        default:
            optionDescription = ""
            optionList = []
        }
        
        initialState = State(
            title: optionType.title,
            optionType: optionType,
            detailOptions: optionList,
            detailOptionDescription: optionDescription,
            selectOption: userSettingRepository.fetchIndex(type: optionType)
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cellSelect(let indexPath):
            let updateIndex = userSettingRepository.updateIndex(
                type: initialState.optionType,
                index: indexPath.row
            )
            return Observable.just(Mutation.settingChange(updateIndex))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .settingChange(let index):
            newState.selectOption = index
        }
        
        return newState
    }
}
