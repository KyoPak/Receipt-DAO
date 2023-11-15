//
//  ViewModelBindable.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

protocol ViewModelBindable: AnyObject {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType? { get set }
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        
        bindViewModel()
    }
}
