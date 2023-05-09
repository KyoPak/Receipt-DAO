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

final class ListViewController: UIViewController, ViewModelBindable {
    var viewModel: ListViewModel?
    
    private var headerView = UIView()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "2023년 04월"
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private var previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        
        return button
    }()
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        return button
    }()
    
    private var todayButton: UIButton = {
        let button = UIButton()
        button.setTitle("현재 달", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        button.backgroundColor = ConstantColor.listColor
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    var tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableView()
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
        appearance.backgroundColor = ConstantColor.backGrouncColor
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backItem?.title = "뒤로가기"
    }
    
    private func setupView() {
        [headerView, tableView].forEach(view.addSubview(_:))
        [titleLabel, previousButton, nextButton, todayButton, tableView].forEach(headerView.addSubview(_:))
        [headerView, titleLabel, previousButton, nextButton, todayButton, tableView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.backgroundColor = ConstantColor.backGrouncColor
    }
    
    private func setupTableView() {
        tableView.backgroundColor = ConstantColor.backGrouncColor
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 45),
            previousButton.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -5),
            previousButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            nextButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            todayButton.widthAnchor.constraint(equalToConstant: 60),
            todayButton.heightAnchor.constraint(equalToConstant: 30),
            todayButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            todayButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
