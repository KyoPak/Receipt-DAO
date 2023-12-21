//
//  CustomNavigationBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

class CustomNavigationBar: UIView {
    
    // UI Properties
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .center
        
        return stackView
    }()
    
    // Initializer
    
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
        [logoView, titleLabel].forEach(titleStackView.addArrangedSubview(_:))
        addSubview(titleStackView)
    }
    
    func setupProperties(title: String) {
        titleLabel.text = title
        backgroundColor = .clear
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            titleStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}
