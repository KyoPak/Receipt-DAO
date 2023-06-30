//
//  SettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

final class SettingViewController: UIViewController, ViewModelBindable {

    var viewModel: SettingViewModel?
    private var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func bindViewModel() {
        
    }
}

extension SettingViewController {
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
    }
}
