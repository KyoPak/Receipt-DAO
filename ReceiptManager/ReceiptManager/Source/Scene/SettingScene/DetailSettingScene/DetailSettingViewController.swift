//
//  DetailSettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

final class DetailSettingViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initializer
    
    init(reactor: DetailSettingReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: DetailSettingReactor) {
        
    }
}
