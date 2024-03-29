//
//  ComposeViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import ReactorKit

final class ComposeViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        case priceTextChanged(String?)
        case imageAppend(Data)
        case cellDeleteButtonTapped(IndexPath?)
        case cellOCRButtonTapped(IndexPath?)
        case ocrRetry
        case registerButtonTapped(SaveExpense)
        case imageAppendButtonTapped(IndexPath)
    }
    
    enum Mutation {
        case loadData
        case chagePriceText(String)
        case imageDataAppend([Data])
        case imageDataDelete([Data])
        case imageDataOCR([String]?)
        case saveExpense(Void?)
        case imageButtonEnable(Bool?)
        case onRegisterError(Error?)
        case onOCRError(Error?, IndexPath?)
    }
    
    struct State {
        var title: String
        var transitionType: TransitionType
        var expense: Receipt
        var priceText: String
        var registerdImageDatas: [Data]
        var imageAppendEnable: Bool?
        var successExpenseRegister: Void?
        var ocrResult: [String]?
        var ocrRetryIndex: IndexPath?
        var ocrError: Error?
        var registerError: Error?
    }
    
    // Custom Type
    
    struct SaveExpense {
        var date: Date
        var store: String?
        var product: String?
        var paymentType: Int
        var memo: String?
    }
    
    enum ControlType {
        case append(Data)
        case delete(Int)
    }
    
    let initialState: State
    
    // Properties
    
    private let expenseRepository: ExpenseRepository
    private let ocrRepository: OCRRepository
    private let userSettingRepository: UserSettingRepository
    
    // Initializer
    
    init(
        expenseRepository: ExpenseRepository,
        ocrRepository: OCRRepository,
        userSettingRepository: UserSettingRepository,
        expense: Receipt? = nil,
        transisionType: TransitionType
    ) {
        self.expenseRepository = expenseRepository
        self.ocrRepository = ocrRepository
        self.userSettingRepository = userSettingRepository
        
        let titleText = transisionType == .modal ?
            ConstantText.registerTitle.localize() : ConstantText.editTitle.localize()
        var imageDatas = expense?.receiptData ?? []
        imageDatas.insert(Data(), at: .zero)
        
        initialState = State(
            title: titleText,
            transitionType: transisionType,
            expense: expense ?? Receipt(paymentType: userSettingRepository.fetchIndex(type: .payment)),
            priceText: NumberFormatter.numberDecimal(from: expense?.priceText ?? ""),
            registerdImageDatas: imageDatas
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.just(Mutation.loadData)
            
        case .priceTextChanged(let text):
            return Observable.just(Mutation.chagePriceText(NumberFormatter.numberDecimal(from: text ?? "")))
            
        case .imageAppend(let data):
            let currentDatas = controlImageData(controlType: .append(data))
            return Observable.just(Mutation.imageDataAppend(currentDatas))
        
        case .cellDeleteButtonTapped(let indexPath):
            guard let indexPath = indexPath else { return Observable.empty() }
            let currentDatas = controlImageData(controlType: .delete(indexPath.row))
            return Observable.just(Mutation.imageDataDelete(currentDatas))
        
        case .cellOCRButtonTapped(let indexPath):
            guard let indexPath = indexPath else { return Observable.empty() }
            return performOCR(indexPath: indexPath)
            
        case .ocrRetry:
            guard let indexPath = currentState.ocrRetryIndex else { return Observable.empty() }
            return performOCR(indexPath: indexPath)
            
        case .registerButtonTapped(let saveExpense):
            let newExpense = convertExpense(expense: currentState.expense, saveExpense)
            return performRegister(expense: newExpense)
            
        case .imageAppendButtonTapped(let indexPath):
            let result = indexPath.row == .zero && currentState.registerdImageDatas.count < 6
            return Observable.concat([
                Observable.just(Mutation.imageButtonEnable(result)),
                Observable.just(Mutation.imageButtonEnable(nil))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData:
            break
            
        case .chagePriceText(let text):
            newState.priceText = text
            
        case .imageDataAppend(let datas), .imageDataDelete(let datas):
            newState.registerdImageDatas = datas
            
        case .saveExpense(let result):
            newState.successExpenseRegister = result
            
        case .imageButtonEnable(let enable):
            newState.imageAppendEnable = enable
            
        case .imageDataOCR(let texts):
            newState.ocrResult = texts
            
        case .onRegisterError(let error):
            newState.registerError = error
            
        case .onOCRError(let error, let indexPath):
            newState.ocrError = error
            newState.ocrRetryIndex = indexPath
        }
        
        return newState
    }
}

// Perform OCR, Register
extension ComposeViewReactor {
    func performOCR(indexPath: IndexPath) -> Observable<Mutation> {
        let ocrTargetData = currentState.registerdImageDatas[indexPath.row]
        return ocrRepository.extractText(by: ocrTargetData)
            .flatMap { texts in
                return Observable.concat([
                    Observable.just(Mutation.imageDataOCR(texts)),
                    Observable.just(Mutation.imageDataOCR(nil))
                ])
            }
            .catch { error in
                Observable.concat([
                    Observable.just(Mutation.onOCRError(error, indexPath)),
                    Observable.just(Mutation.onOCRError(nil, indexPath))
                ])
            }
    }
    
    func performRegister(expense: Receipt) -> Observable<Mutation> {
        return expenseRepository.save(expense: expense)
            .flatMap { _ in
                Observable.concat([
                    Observable.just(Mutation.saveExpense(Void())),
                    Observable.just(Mutation.saveExpense(nil))
                ])
            }
            .catch { error in
                Observable.concat([
                    Observable.just(Mutation.onRegisterError(error)),
                    Observable.just(Mutation.onRegisterError(nil))
                ])
            }
    }
}

extension ComposeViewReactor {
    private func controlImageData(controlType: ControlType) -> [Data] {
        var currentDatas = currentState.registerdImageDatas
        
        switch controlType {
        case .append(let data):
            currentDatas.append(data)
        case .delete(let index):
            currentDatas.remove(at: index)
        }
        
        return currentDatas
    }
    
    private func convertExpense(expense: Receipt, _ data: SaveExpense) -> Receipt {
        let imageDatas = controlImageData(controlType: .delete(.zero))
        
        var expense = expense
        expense.store = data.store ?? ""
        expense.priceText = currentState.priceText.replacingOccurrences(of: ",", with: "")
        expense.product = data.product ?? ""
        expense.receiptDate = data.date
        expense.paymentType = data.paymentType
        expense.receiptData = imageDatas
        expense.memo = data.memo ?? ""
        
        return expense
    }
}
