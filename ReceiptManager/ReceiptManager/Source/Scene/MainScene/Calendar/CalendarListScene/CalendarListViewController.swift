//
//  CalendarListViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CalendarListViewController: UIViewController, View {

    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initializer
    
    init(reactor: CalendarListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CalendarListReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension CalendarListViewController {
    private func bindView() {
        
    }
    
    private func bindAction(_ reactor: CalendarListReactor) {
        
    }
    
    private func bindState(_ reactor: CalendarListReactor) {
        
    }
}

// MARK: - UIConstraints
extension CalendarListViewController {
    private func setupHierarchy() {
        
    }
    
    func setupProperties() {
        
    }
    
    private func setupContraints() {
        
    }
}
