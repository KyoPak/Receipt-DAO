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
        button.setTitle("목록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "list.bullet", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(red: 42/255, green: 201/255, blue: 231/255, alpha: 1)
        
        return button
    }()
    
    private let favoriteListButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle("즐겨찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "star", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(red: 203/255, green: 190/255, blue: 215/255, alpha: 1)
        
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.setTitle("등록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.alignTextBelow()
        button.backgroundColor = UIColor(red: 197/255, green: 235/255, blue: 167/255, alpha: 1)
        
        return button
    }()
    
    private let monthSpendingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.font = .preferredFont(forTextStyle: .title3, compatibleWith: .none)
        label.backgroundColor = UIColor(red: 36/255, green: 52/255, blue: 78/255, alpha: 1)
        label.text = "5월 지출 내역은 123123원 입니다."
        
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
    }
}

extension MainViewController {
    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 25/255, green: 41/255, blue: 67/255, alpha: 1)
        [titleView, listButton, favoriteListButton, addButton, monthSpendingLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [titleView, listButton, favoriteListButton, addButton, monthSpendingLabel]
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
            
            addButton.topAnchor.constraint(equalTo: favoriteListButton.bottomAnchor, constant: 30),
            addButton.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            addButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.2),
            
            monthSpendingLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 50),
            monthSpendingLabel.leadingAnchor.constraint(equalTo: listButton.leadingAnchor),
            monthSpendingLabel.trailingAnchor.constraint(equalTo: favoriteListButton.trailingAnchor),
            monthSpendingLabel.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1)
        ])
    }
}
