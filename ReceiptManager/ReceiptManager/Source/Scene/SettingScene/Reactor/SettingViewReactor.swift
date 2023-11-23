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
        case sendMail(String?)
        case rankApp(String?)
    }
    
    struct State {
        var settingMenu: [SettingSection]
        var mailURL: String?
        var appStoreURL: String?
    }
    
    let initialState: State
    
    // Properties
    
    // Initializer
    
    init() {
        initialState = State(settingMenu: [], mailURL: nil, appStoreURL: nil)
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
            
        case .sendMail(let url):
            newState.mailURL = url
            
        case .rankApp(let url):
            newState.appStoreURL = url
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
                Observable.just(Mutation.sendMail(
                    createEmailUrl(
                        subject: ConstantText.mailSubject.localize(),
                        body: ConstantText.mailBody.localize()
                    )
                )),
                Observable.just(Mutation.sendMail(nil))
            ])
        case .appStore:
            return Observable.concat([
                Observable.just(Mutation.rankApp(createAppStoreURL())),
                Observable.just(Mutation.rankApp(nil))
            ])
        }
    }
    
    private func createEmailUrl(subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let defaultUrl = "mailto:\(ConstantText.myEmail)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        return defaultUrl
    }
    
    private func createAppStoreURL() -> String {
        return "itms-apps://itunes.apple.com/app/" + ConstantText.appID
    }
}
