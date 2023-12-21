//
//  CustomItemView.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

import RxSwift

final class CustomItemView: UIView {
    
    // Properties
    
    private let item: CustomTabItem
    
    let index: Int
    
    var isSelected = false {
        didSet {
            animateItems()
        }
    }
    
    // UI Properties
    
    private let nameLabel = UILabel()
    private let iconImageView = UIImageView()
    private let underlineView = UIView()
    private let containerView = UIView()
    
    // Initializer
    
    init(with item: CustomTabItem, index: Int) {
        self.item = item
        self.index = index
        super.init(frame: .zero)
        setupHierarchy()
        setupConstraints()
        setupProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Animation
extension CustomItemView {
    func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            } completion: { _ in completion() }
        }
    }
    
    private func animateItems() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.nameLabel.alpha = self.isSelected ? 0.0 : 1.0
            self.underlineView.alpha = self.isSelected ? 1.0 : 0.0
        }
        UIView.transition(
            with: iconImageView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [weak self] in
            guard let self = self else { return }
            self.iconImageView.image = self.isSelected ? self.item.selectedIcon : self.item.icon
        }
    }
}

// MARK: - UI Constraints
extension CustomItemView {
    private func setupHierarchy() {
        [nameLabel, iconImageView, underlineView, containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nameLabel, iconImageView, underlineView].forEach { containerView.addSubview($0) }
        addSubview(containerView)
    }
    
    private func setupProperties() {
        nameLabel.text = item.name
        nameLabel.textColor = .label.withAlphaComponent(0.4)
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        
        underlineView.backgroundColor = .label
        underlineView.layer.cornerRadius = 2
        
        iconImageView.image = isSelected ? item.selectedIcon : item.icon
    }
    
    private func setupConstraints() {
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            iconImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 35),
            iconImageView.widthAnchor.constraint(equalToConstant: 35),
            
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            underlineView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            underlineView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 4),
            underlineView.widthAnchor.constraint(equalToConstant: 40),
            
            containerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
}
