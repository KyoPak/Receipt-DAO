//
//  SettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class SettingViewController: UIViewController, ViewModelBindable {

    var viewModel: SettingViewModel?
    private var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    func bindViewModel() {
        viewModel?.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
    }
}

extension SettingViewController {
    @objc private func tapCloseButton() {
        viewModel?.cancelAction()
    }
}

extension SettingViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ConstantColor.backGrouncColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: ConstantText.close.localize(),
            style: .plain,
            target: self,
            action: #selector(tapCloseButton)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
    }
}
