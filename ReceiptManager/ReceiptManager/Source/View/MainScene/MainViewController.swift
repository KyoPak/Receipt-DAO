//
//  MainViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit

final class MainViewController: UIViewController {
    private let listButton: UIButton = {
        let button = UIButton()
        button.setTitle("목록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black

        button.layer.cornerRadius = 10
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "list.bullet", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.backgroundColor = UIColor(red: 42/255, green: 201/255, blue: 231/255, alpha: 1)
        button.imageEdgeInsets = UIEdgeInsets(top: -40, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -image!.size.width, bottom: 0, right: 0)
        return button
    }()
    
    private let favoriteListButton: UIButton = {
        let button = UIButton()
        button.setTitle("즐겨찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        
        button.layer.cornerRadius = 10
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "star.fill", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
        button.backgroundColor = UIColor(red: 203/255, green: 190/255, blue: 215/255, alpha: 1)
        button.imageEdgeInsets = UIEdgeInsets(top: -40, left: 45, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -image!.size.width, bottom: 0, right: 0)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("등록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        
        button.layer.cornerRadius = 10
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)

        button.backgroundColor = UIColor(red: 197/255, green: 235/255, blue: 167/255, alpha: 1)
        button.imageEdgeInsets = UIEdgeInsets(top: -40, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -image!.size.width, bottom: 0, right: 0)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupContraints()
    }
}

extension MainViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 25/255, green: 41/255, blue: 67/255, alpha: 1)
        [listButton, favoriteListButton, addButton, monthSpendingLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [listButton, favoriteListButton, addButton, monthSpendingLabel].forEach(view.addSubview(_:))
    }
    
    private func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            listButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 100),
            listButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            listButton.trailingAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: -10),
            listButton.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.3),
            
            favoriteListButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 100),
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
