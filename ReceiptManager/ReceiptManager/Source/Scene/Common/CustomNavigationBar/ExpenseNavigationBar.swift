//
//  ExpenseNavigationBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import UIKit

final class ExpenseNavigationBar: CustomNavigationBar {
    
    // UI Properties
    
    let showModeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: ConstantImage.calendar)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: ConstantImage.searchOrigin)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    // Initializer
    
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
        [showModeButton, searchButton].forEach(addSubview(_:))
    }
    
    override func setupProperties(title: String) {
        super.setupProperties(title: title)
                
        [showModeButton, searchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            showModeButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -20),
            showModeButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            
            searchButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            searchButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    func changShowModeButton(_ mode: ShowMode) {
        switch mode {
        case .list:
            showModeButton.setImage(UIImage(systemName: ConstantImage.calendar), for: .normal)
        
        case .calendar:
            showModeButton.setImage(UIImage(systemName: ConstantImage.list), for: .normal)
        }
    }
}
