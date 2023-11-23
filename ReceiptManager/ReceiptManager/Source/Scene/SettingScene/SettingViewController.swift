//
//  SettingViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/30.
//

import UIKit

import ReactorKit
import RxDataSources
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController, View {

    // Properties
    
    typealias TableViewDataSource = RxTableViewSectionedReloadDataSource<SettingSection>
    
    private let dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingCell.identifier,
                for: indexPath
            ) as? SettingCell else {
                return UITableViewCell()
            }
            
            if indexPath.section == .zero {
                cell.showSegment(index: UserDefaults.standard.integer(forKey: ConstantText.currencyKey))
            }
            
            cell.setupData(text: item.title)
            return cell
        }
        
        return dataSource
    }()
    var disposeBag = DisposeBag()
    weak var coordinator: SettingViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = CustomNavigationBar(title: ConstantText.setting.localize())
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: SettingViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SettingViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension SettingViewController {
    private func bindView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: SettingViewReactor) {
        rx.methodInvoked(#selector(viewWillAppear))
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .do { self.tableView.deselectRow(at: $0, animated: false) }
            .map { Reactor.Action.cellSelect($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: SettingViewReactor) {
        reactor.state.map { $0.settingMenu }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.url }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive { UIApplication.shared.open($0) }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let datas = reactor?.currentState.settingMenu else { return nil }
        let data = datas[section]
        let sectionTitle = data.title
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .label
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

// MARK: - UI Constrints
extension SettingViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHierarchy() {
        [navigationBar, tableView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        tableView.backgroundColor = ConstantColor.backGroundColor
        [navigationBar, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
