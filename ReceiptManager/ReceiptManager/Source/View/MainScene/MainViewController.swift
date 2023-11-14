//
//  MainViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class MainViewController: UIViewController, ViewModelBindable {
    var viewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContraints()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
    }
}

// MARK: - UIConstraints
extension MainViewController {
    private func setupView() {
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
        ])
    }
}
