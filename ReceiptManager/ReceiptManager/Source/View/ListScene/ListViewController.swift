//
//  ListViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ListViewController: UIViewController, ViewModelBindable {
    var viewModel: ListViewModel?
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupConstraints()
    }
    
    func bindViewModel() {
        viewModel?.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
    }
}

extension ListViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 25/255, green: 41/255, blue: 67/255, alpha: 1)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backItem?.title = "뒤로가기"
        
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 25/255, green: 41/255, blue: 67/255, alpha: 1)
        
    }
    
    private func setupConstraints() {
        
    }
}
