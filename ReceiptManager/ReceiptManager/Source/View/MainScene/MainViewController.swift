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
    
    private let navigationBar = ExpenseNavigationBar(title: "나의 지출")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupNavigationBar()
        setupContraints()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
    }
}

// MARK: - UIConstraints
extension MainViewController {
    private func setupHierarchy() {
        view.addSubview(navigationBar)
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    func setupProperties() {
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupNavigationBar() {
        title = ConstantText.list.localize()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
