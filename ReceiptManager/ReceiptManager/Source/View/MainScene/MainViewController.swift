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
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.list.localize(), for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.list, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = ConstantColor.listColor
        
        return button
    }()
    
    private let favoriteListButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.bookMark.localize(), for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.bookMark, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = ConstantColor.favoriteColor
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle(ConstantText.register.localize(), for: .normal)
        button.setTitleColor(ConstantColor.backGrouncColor, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.plus, withConfiguration: imageConfig)
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
    
    private let settingButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBackground
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: ConstantImage.setting, withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
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
        backBarButtonItem.tintColor = .white
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func setupView() {
        view.backgroundColor = ConstantColor.backGrouncColor
        
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
            
            settingButton.topAnchor.constraint(equalTo: monthSpendingLabel.bottomAnchor, constant: 40),
            settingButton.trailingAnchor.constraint(equalTo: monthSpendingLabel.trailingAnchor)
        ])
    }
}
