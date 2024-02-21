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
    }
    
    enum Mutation {
        case loadData([SettingSection])
        case movePrivateSetting((OptionKeyType, SettingType)?)
        case moveURL(URL?)
    }
    
    struct State {
        var settingMenu: [SettingSection]
        var selectOptions: (OptionKeyType, SettingType)?
        var url: URL?
    }
    
    let initialState: State
    
    // Properties
    
    private let currencyRepository: UserSettingRepository
    
    // Initializer
    
    init(currencyRepository: UserSettingRepository) {
        self.currencyRepository = currencyRepository
        
        initialState = State(settingMenu: [])
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let menu):
            newState.settingMenu = menu
            
        case .movePrivateSetting(let options):
            newState.selectOptions = options
            
        case .moveURL(let url):
            newState.url = url
        }
        
        return newState
    }
}

extension SettingViewReactor {
    private func classifySettingType(_ type: SettingType) -> Observable<Mutation> {
        switch type {
        case .currency:
            return Observable.concat([
                Observable.just(Mutation.movePrivateSetting((.currency, type))),
                Observable.just(Mutation.movePrivateSetting(nil))
            ])
            
        case .payment:
            return Observable.concat([
                Observable.just(Mutation.movePrivateSetting((.payment, type))),
                Observable.just(Mutation.movePrivateSetting(nil))
            ])
            
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
