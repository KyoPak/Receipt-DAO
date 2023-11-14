//
//  ExpenseNavigationBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class ExpenseNavigationBar: CustomNavigationBar {
    let logoView = UIImageView()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: ConstantImage.searchOrigin)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    init(title: String, imageName: String) {
        super.init(title: title)

        setupHierarchy()
        self.setupProperties(title: title, imageName: imageName)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        [logoView, searchButton].forEach(addSubview(_:))
    }
    
    func setupProperties(title: String, imageName: String) {
        super.setupProperties(title: title)
        
        logoView.image = UIImage(named: imageName)
        logoView.contentMode = .scaleAspectFit
        
        [logoView, searchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            
            logoView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 3),
            logoView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),

            searchButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            searchButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}
