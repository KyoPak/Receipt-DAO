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
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupView()
        setupConstraint()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.menuDatas
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
            
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let datas = try? viewModel?.menuDatas.value() else {
            return .zero
        }
        
        return datas[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let datas = try? viewModel?.menuDatas.value() else {
            return nil
        }
        
        let data = datas[section]
        
        let sectionTitle = data.title
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.text = sectionTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "HeaderView")

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension SettingViewController {
    @objc private func tapCloseButton() {
        viewModel?.cancelAction()
    }
}

// MARK: - UI Constrints
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
    
    private func setupTableView() {
        tableView.backgroundColor = ConstantColor.backGrouncColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        view.addSubview(tableView)
    }
    
    private func setupConstraint() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
