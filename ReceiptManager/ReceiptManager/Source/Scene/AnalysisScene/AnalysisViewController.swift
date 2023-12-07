//
//  AnalysisViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/7/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class AnalysisViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: AnalysisViewCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initializer
    
    init(reactor: AnalysisViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: AnalysisViewReactor) {
        
    }
}
