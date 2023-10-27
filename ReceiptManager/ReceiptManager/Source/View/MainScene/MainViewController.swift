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
    
    private let listButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.label
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(named: "Layer")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle(ConstantText.list.localize(), for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.list, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(named: "Cell")
        
        return button
    }()
    
    private let favoriteListButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.label
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(named: "Layer")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle(ConstantText.bookMark.localize(), for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.bookMark, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(named: "Cell")
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBackground
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(named: "Layer")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle(ConstantText.register.localize(), for: .normal)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.plus, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(named: "Main")
        
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = UIColor(named: "Cell")
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.tintColor = .label
        searchBar.searchTextField.textColor = .label
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.searchTextField.leftView?.tintColor = .label
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "Layer")?.cgColor
        searchBar.searchTextField.backgroundColor = UIColor(named: "Cell")
        searchBar.setImage(UIImage(systemName: ConstantImage.searchXCircle), for: .clear, state: .normal)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: ConstantText.searchBar.localize(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        return searchBar
    }()
    
    private let monthSpendingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(named: "Layer")?.cgColor
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.font = .preferredFont(forTextStyle: .title3, compatibleWith: .none)
        label.backgroundColor = UIColor(named: "Cell")
        
        return label
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.label
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor(named: "Layer")?.cgColor
        button.layer.borderWidth = 1
//        button.setTitle(ConstantText.setting.localize(), for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let image = UIImage(systemName: ConstantImage.setting, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(named: "Cell")
        
        return button
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
        
        viewModel.title
            .drive(titleView.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        listButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveListAction()
            }
            .disposed(by: rx.disposeBag)
        
        registerButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveRegisterAction()
            }
            .disposed(by: rx.disposeBag)
        
        favoriteListButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveFavoriteAction()
            }
            .disposed(by: rx.disposeBag)
        
        settingButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveSettingAction()
            }
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveSearchAction()
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.receiptCountText
            .drive(monthSpendingLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UIConstraints
extension MainViewController {
    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        
        let backBarButtonItem = UIBarButtonItem(
            title: ConstantText.home.localize(), style: .plain, target: self, action: nil
        )
        backBarButtonItem.tintColor = .label
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "BackGround")
        
        [titleView, searchBar, listButton, favoriteListButton,
         registerButton, monthSpendingLabel, settingButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [titleView, searchBar, listButton, favoriteListButton,
         registerButton, monthSpendingLabel, settingButton]
            .forEach(view.addSubview(_:))
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            searchBar.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 30),
            searchBar.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor),
            
            listButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            listButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            listButton.trailingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: -5),
            listButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            favoriteListButton.topAnchor.constraint(equalTo: listButton.bottomAnchor, constant: 10),
            favoriteListButton.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            favoriteListButton.trailingAnchor.constraint(equalTo: listButton.trailingAnchor),
            favoriteListButton.heightAnchor.constraint(equalTo: listButton.heightAnchor),
            
            registerButton.topAnchor.constraint(equalTo: listButton.topAnchor),
            registerButton.leadingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 5),
            registerButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            registerButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.3),
            
            settingButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 10),
            settingButton.leadingAnchor.constraint(equalTo: registerButton.leadingAnchor),
            settingButton.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor),
            settingButton.bottomAnchor.constraint(equalTo: favoriteListButton.bottomAnchor),
            
            monthSpendingLabel.topAnchor.constraint(equalTo: favoriteListButton.bottomAnchor, constant: 30),
            monthSpendingLabel.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            monthSpendingLabel.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor),
            monthSpendingLabel.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1)
        ])
    }
}
