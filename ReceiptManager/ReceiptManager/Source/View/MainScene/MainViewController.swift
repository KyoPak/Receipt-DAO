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
        viewModel?.title
            .drive(titleView.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        listButton.rx.tap
            .subscribe(onNext: { [weak self] in
            self?.viewModel?.moveListAction()
        })
        .disposed(by: rx.disposeBag)
        
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.moveRegisterAction()
            })
            .disposed(by: rx.disposeBag)
        
        favoriteListButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.moveFavoriteAction()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel?.receiptCountText
            .drive(monthSpendingLabel.rx.text)
            .disposed(by: rx.disposeBag)
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
        [titleView, listButton, favoriteListButton, registerButton, monthSpendingLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [titleView, listButton, favoriteListButton, registerButton, monthSpendingLabel]
            .forEach(view.addSubview(_:))
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            listButton.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 30),
            listButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            listButton.trailingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: -10),
            listButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.3),
            
            favoriteListButton.topAnchor.constraint(equalTo: listButton.topAnchor),
            favoriteListButton.leadingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 10),
            favoriteListButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            favoriteListButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.3),
            
            registerButton.topAnchor.constraint(equalTo: favoriteListButton.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            registerButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            monthSpendingLabel.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 50),
            monthSpendingLabel.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            monthSpendingLabel.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            monthSpendingLabel.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1)
        ])
    }
}
