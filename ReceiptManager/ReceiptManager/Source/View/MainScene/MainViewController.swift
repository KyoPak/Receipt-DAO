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
    private let titleView = TitleView()
    
    private var searchBarTopConstraint: NSLayoutConstraint?
    
    private let searchView = SearchView()
    
    private let listButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.list, for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "list.bullet", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = ConstantColor.listColor
        
        return button
    }()
    
    private let favoriteListButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.bookMark, for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "bookmark", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = ConstantColor.favoriteColor
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.register, for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = ConstantColor.registerColor
        
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = ConstantColor.cellColor
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.tintColor = .white
        searchBar.searchTextField.leftView?.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = ConstantColor.cellColor
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.setImage(UIImage(systemName: "x.circle.fill"), for: .clear, state: .normal)
        
        return searchBar
    }()
    
    private let searchBarBackButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "chevron.backward")
        button.setImage(image, for: .normal)

        return button
    }()
    
    private let searchBarOriginalButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)

        return button
    }()
    
    private let monthSpendingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.font = .preferredFont(forTextStyle: .title3, compatibleWith: .none)
        label.backgroundColor = ConstantColor.cellColor
        
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContraints()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        bindSearchBar()
        
        viewModel.title
            .drive(titleView.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        listButton.rx.tap
            .bind { [weak self] in
                self?.viewModel?.moveListAction()
            }
            .disposed(by: rx.disposeBag)
        
        registerButton.rx.tap
            .bind { [weak self] in
                self?.viewModel?.moveRegisterAction()
            }
            .disposed(by: rx.disposeBag)
        
        favoriteListButton.rx.tap
            .bind { [weak self] in
                self?.viewModel?.moveFavoriteAction()
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.receiptCountText
            .drive(monthSpendingLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    private func bindSearchBar() {
        guard let viewModel = viewModel else { return }
        
        searchBar.rx.textDidBeginEditing
            .bind { [weak self] in
                self?.moveUpSearchBar()
            }
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.textDidEndEditing
            .bind { [weak self] in
                self?.moveDownSearchBar()
                self?.searchBar.searchTextField.text = ""
            }
            .disposed(by: rx.disposeBag)
        
        searchBarBackButton.rx.tap
            .bind { [weak self] in
                self?.searchBar.endEditing(true)
            }
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { text in
                self.viewModel?.search(text)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.searchResultList
            .bind(to: searchView.tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)

        searchBar.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        searchView.tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

extension MainViewController: UISearchBarDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
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

// MARK: - UIConstraints
extension MainViewController {
    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        
        let backBarButtonItem = UIBarButtonItem(
            title: ConstantText.home, style: .plain, target: self, action: nil
        )
        backBarButtonItem.tintColor = .white
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        searchView.isHidden = true
        
        [titleView, searchBar, listButton, favoriteListButton, registerButton, monthSpendingLabel, searchView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [titleView, searchBar, listButton, favoriteListButton, registerButton, monthSpendingLabel, searchView]
            .forEach(view.addSubview(_:))
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 30)
        searchBarTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            searchBar.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            
            listButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            listButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            listButton.trailingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: -10),
            listButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            favoriteListButton.topAnchor.constraint(equalTo: listButton.topAnchor),
            favoriteListButton.leadingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 10),
            favoriteListButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            favoriteListButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            registerButton.topAnchor.constraint(equalTo: favoriteListButton.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            registerButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.15),
            
            monthSpendingLabel.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 30),
            monthSpendingLabel.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            monthSpendingLabel.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            monthSpendingLabel.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            searchView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
            searchView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func configureSearchView(hidden: Bool) {
        searchBar.searchTextField.leftView = hidden ? searchBarOriginalButton : searchBarBackButton
        searchView.isHidden = hidden
        [titleView, listButton, favoriteListButton, registerButton, monthSpendingLabel].forEach {
            $0.isHidden = !hidden
        }
    }
    
    private func moveDownSearchBar() {
        configureSearchView(hidden: true)
        
        UIView.animate(withDuration: 0.2) {
            self.searchBarTopConstraint?.isActive = false
            self.searchBarTopConstraint = self.searchBar.topAnchor.constraint(
                equalTo: self.titleView.bottomAnchor,
                constant: 30
            )
            self.searchBarTopConstraint?.isActive = true
        }
    }
    
    private func moveUpSearchBar() {
        configureSearchView(hidden: false)
        
        UIView.animate(withDuration: 0.3) {
            self.searchBarTopConstraint?.isActive = false
            self.searchBarTopConstraint = self.searchBar.topAnchor.constraint(
                equalTo: self.titleView.topAnchor
            )
            self.searchBarTopConstraint?.isActive = true
        }
    }
}
