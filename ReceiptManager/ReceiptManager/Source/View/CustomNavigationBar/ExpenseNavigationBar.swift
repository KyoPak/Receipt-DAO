//
//  ExpenseNavigationBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class ExpenseNavigationBar: CustomNavigationBar {
    private let searchButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: ConstantImage.searchOrigin)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    override init(title: String) {
        super.init(title: title)

        setupHierarchy()
        self.setupProperties(title: title)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupHierarchy() {
        super.setupHierarchy()
        [searchButton].forEach(addSubview(_:))
    }
    
    override func setupProperties(title: String) {
        super.setupProperties(title: title)
                
        [searchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            searchButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            searchButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}
