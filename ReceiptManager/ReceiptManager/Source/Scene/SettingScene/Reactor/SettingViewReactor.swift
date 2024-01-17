//
//  SettingViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/23.
//

import ReactorKit

final class SettingViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        case cellSelect(IndexPath)
        case segmentValueChanged(Int)
    }
    
    enum Mutation {
        case loadData([SettingSection])
        case moveURL(URL?)
        case currencyChange(Int)
    }
    
    struct State {
        var settingMenu: [SettingSection]
        var url: URL?
        var currencyIndex: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let currencyRepository: CurrencyRepository
    
    // Initializer
    
    init(currencyRepository: CurrencyRepository) {
        self.currencyRepository = currencyRepository
        
        initialState = State(settingMenu: [], url: nil, currencyIndex: .zero)
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let settingMenu = SettingSection.configureSettings()
            return Observable.merge([
                Observable.just(Mutation.loadData(settingMenu)),
                currencyRepository.saveEvent.asObservable().map { Mutation.currencyChange($0) }
            ])
        
        case .cellSelect(let indexPath):
            let settingType = currentState.settingMenu[indexPath.section].items[indexPath.row].type
            return classifySettingType(settingType)
            
        case .segmentValueChanged(let index):
            return currencyRepository.updateCurrency(index: index)
                .flatMap { Observable.just(Mutation.currencyChange($0)) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let menu):
            newState.settingMenu = menu
            
        case .moveURL(let url):
            newState.url = url
            
        case .currencyChange(let index):
            newState.currencyIndex = index
        }
        
        return newState
    }
}

extension SettingViewReactor {
    private func classifySettingType(_ type: SettingType) -> Observable<Mutation> {
        switch type {
        case .currency:
            return Observable.empty()
        case .mail:
            return Observable.concat([
                Observable.just(Mutation.moveURL(createEmailUrl())),
                Observable.just(Mutation.moveURL(nil))
            ])
        case .appStore:
            return Observable.concat([
                Observable.just(Mutation.moveURL(createAppStoreURL())),
                Observable.just(Mutation.moveURL(nil))
            ])
        }
    }
    
    private func createEmailUrl() -> URL? {
        let subject = ConstantText.mailSubject.localize()
        let body = ConstantText.mailBody.localize()
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let defaultUrl = "mailto:\(ConstantText.myEmail)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        return URL(string: defaultUrl)
    }
    
    private func createAppStoreURL() -> URL? {
        return URL(string: "itms-apps://itunes.apple.com/app/" + ConstantText.appID)
    }
}
