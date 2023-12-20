//
//  AlertView.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import UIKit

import RxCocoa
import RxSwift

final class AlertView: UIView {
    
    // Properties
    
    var didTapCancelButton: ControlEvent<Void> {
        return cancelButton.rx.controlEvent(.touchUpInside)
    }
    private let disposeBag = DisposeBag()
    
    // UI Properties
    
    let mainLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.cancle.localize(), for: .normal)
        button.backgroundColor = .systemGray3
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Constraints
private extension AlertView {
    func setupHierarchy() {
        [mainLabel, cancelButton].forEach(addSubview(_:))
    }
    
    func setupProperties() {
        [mainLabel, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupContraints() {
        NSLayoutConstraint.activate([
            
            mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3)
        ])
    }
}
