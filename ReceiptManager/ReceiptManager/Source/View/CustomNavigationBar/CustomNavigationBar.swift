//
//  CustomNavigationBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

class CustomNavigationBar: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        setupHierarchy()
        setupProperties(title: title)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHierarchy() {
        [titleLabel].forEach(addSubview(_:))
    }
    
    func setupProperties(title: String) {
        titleLabel.text = title
        backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        ])
    }
}
