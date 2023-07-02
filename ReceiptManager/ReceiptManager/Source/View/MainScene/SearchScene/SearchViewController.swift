//
//  SearchView.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/08.
//

import UIKit
import RxCocoa
import RxSwift

final class SearchViewController: UIViewController, ViewModelBindable {
    var viewModel: SearchViewModel?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = ConstantColor.cellColor
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.searchTextField.leftView?.tintColor = .white
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
        button.tintColor = .white
        let image = UIImage(systemName: ConstantImage.searchBack)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        searchBar.rx.textDidEndEditing
            .withUnretained(self)
            .bind { (owner, _) in
                owner.searchBar.resignFirstResponder()
            }
            .disposed(by: rx.disposeBag)

        searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .bind { (owner, _) in
                owner.searchBar.endEditing(true)
            }
            .disposed(by: rx.disposeBag)
        
        searchBarBackButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.cancelAction()
            }
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchText)
            .disposed(by: rx.disposeBag)
        
        viewModel.searchResultList
            .do(onNext: { [weak self] datas in
                datas.isEmpty ? self?.showEmptyResultMessage() : self?.hideEmptyResultMessage()
            })
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        Observable.zip(
            tableView.rx.modelSelected(Receipt.self),
            tableView.rx.itemSelected
        )
        .withUnretained(self)
        .do { (owner, data) in
            owner.tableView.deselectRow(at: data.1, animated: true)
        }
        .map { $1.0 }
        .subscribe { [weak self] in
            self?.viewModel?.moveDetailAction(receipt: $0)
        }
        .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
    }
    
    private func setupView() {
        searchBar.becomeFirstResponder()
        view.backgroundColor = ConstantColor.backGrouncColor

        searchBar.searchTextField.leftView = searchBarBackButton
        tableView.backgroundColor = ConstantColor.backGrouncColor
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        
        [searchBar, tableView].forEach(view.addSubview(_:))
        [searchBar, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraint() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = viewModel?.dataSource[section]
        
        let string = data?.identity
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.text = string
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
          label.text = searchBar.text == "" ? ConstantText.searchText.localize() : ConstantText.searchFail.localize()
          label.textColor = .white
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
