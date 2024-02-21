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
//        case viewWillAppear
//        case cellSelect(IndexPath)
    }
    
    enum Mutation {
        
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
    
    // Initializer
    
    init(optionType: OptionKeyType, settingType: SettingType) {
        switch settingType {
        case .currency(let description, let options), .payment(let description, let options):
            initialState = State(
                title: optionType.title,
                optionType: optionType,
                detailOptions: options,
                detailOptionDescription: description,
                selectOption: .zero
            )
            
        default:
            fatalError()
        }
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
