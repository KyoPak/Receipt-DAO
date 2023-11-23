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
        case userdefaultCurrencyChange(Int)
    }
    
    struct State {
        var settingMenu: [SettingSection]
        var url: URL?
        var currencyIndex: Int
    }
    
    let initialState: State
    
    // Properties
    
    // Initializer
    
    init() {
        initialState = State(
            settingMenu: [],
            url: nil,
            currencyIndex: UserDefaults.standard.integer(forKey: ConstantText.currencyKey)
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let settingMenu = SettingSection.configureSettings()
            return Observable.just(Mutation.loadData(settingMenu))
        
        case .cellSelect(let indexPath):
            let settingType = currentState.settingMenu[indexPath.section].items[indexPath.row].type
            return classifySettingType(settingType)
            
        case .segmentValueChanged(let index):
            UserDefaults.standard.set(index, forKey: ConstantText.currencyKey)
            return Observable.just(Mutation.userdefaultCurrencyChange(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let menu):
            newState.settingMenu = menu
            
        case .moveURL(let url):
            newState.url = url
            
        case .userdefaultCurrencyChange(let index):
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
