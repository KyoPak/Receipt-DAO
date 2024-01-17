//
//  SearchView.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/08.
//

import UIKit

import ReactorKit
import RxDataSources
import RxCocoa
import RxSwift

final class SearchViewController: UIViewController, View {
    
    // Properties
    
    typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
    
    private lazy var dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource { [weak self] dataSource, tableView, indexPath, receipt in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier, for: indexPath
            ) as? ListTableViewCell else {
                let cell = UITableViewCell()
                return cell
            }
            
            cell.reactor = ListTableViewCellReactor(
                expense: receipt,
                userDefaultEvent: self?.reactor?.currencyEvent ?? BehaviorSubject<Int>(value: .zero)
            )
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _, _ in return true }
        
        return dataSource
    }()
    
    var disposeBag = DisposeBag()
    weak var coordinator: SearchViewCoordinator?
    
    // UI Properties
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = ConstantColor.cellColor
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.tintColor = .label
        searchBar.searchTextField.textColor = .label
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.searchTextField.leftView?.tintColor = .label
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = ConstantColor.layerColor.cgColor
        searchBar.searchTextField.backgroundColor = ConstantColor.cellColor
        searchBar.setImage(UIImage(systemName: ConstantImage.searchXCircle), for: .clear, state: .normal)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: ConstantText.searchBar.localize(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        return searchBar
    }()
    
    private let searchBarBackButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: ConstantImage.searchBack)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // Initializer
    
    init(reactor: SearchViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SearchViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension SearchViewController {
    private func bindView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        searchBar.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .bind { (owner, _) in
                owner.searchBar.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        searchBarBackButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.coordinator?.close(owner.navigationController ?? UINavigationController())
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Receipt.self), tableView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { (owner, data) in
                owner.tableView.deselectRow(at: data.1, animated: true)
            })
            .map { $1.0 }
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.presentDetailView(expense: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: SearchViewReactor) {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.searchExpense($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: SearchViewReactor) {
        reactor.state.map { $0.searchResult }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] datas in
                datas.isEmpty ? self?.showEmptyResultMessage() : self?.hideEmptyResultMessage()
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = dataSource[section]

        let headerText = data.identity
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .label
        label.text = headerText
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

extension SearchViewController: UISearchBarDelegate {
    private func showEmptyResultMessage() {
        let label = UILabel()
          label.text = searchBar.text == "" ?
            ConstantText.searchText.localize() : ConstantText.searchFail.localize()
          label.textColor = .label
          label.textAlignment = .center
          label.translatesAutoresizingMaskIntoConstraints = false

          tableView.backgroundView = label
          
          NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
                label.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 50)
          ])
    }
    
    private func hideEmptyResultMessage() {
        tableView.backgroundView = nil
    }
}

// MARK: - UI Constraints
extension SearchViewController {
    private func setupHierarchy() {
        [searchBar, tableView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        searchBar.becomeFirstResponder()
        searchBar.searchTextField.leftView = searchBarBackButton
        
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        [searchBar, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
