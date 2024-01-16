//
//  AlertView.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import UIKit

import RxCocoa
import RxSwift

protocol Retriable: AnyObject {
    func retry()
}

final class AlertView: UIView {
    
    // Properties
    
    var didTapCancelButton: ControlEvent<Void> {
        return cancelButton.rx.controlEvent(.touchUpInside)
    }
    
    var didTapRetryButton: ControlEvent<Void> {
        return retryButton.rx.controlEvent(.touchUpInside)
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
    
    private let retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("재시도", for: .normal)
        button.backgroundColor = .systemGray3
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    // Initializer
    
    init(alertType: AlertType = .cancel) {        
        super.init(frame: .zero)
        setupHierarchy(alertType: alertType)
        setupProperties()
        setupContraints(alertType: alertType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Constraints
private extension AlertView {
    func setupHierarchy(alertType: AlertType) {
        switch alertType {
        case .retry:
            [mainLabel, retryButton, cancelButton].forEach(addSubview(_:))
        case .cancel:
            [mainLabel, cancelButton].forEach(addSubview(_:))
        }
    }
    
    func setupProperties() {
        [mainLabel, retryButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupContraints(alertType: AlertType) {
        NSLayoutConstraint.activate([
            mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20)
        ])
        
        switch alertType {
        case .retry:
            NSLayoutConstraint.activate([
                retryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                retryButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -1),
                retryButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                retryButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
                
                cancelButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 1),
                cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor),
                cancelButton.heightAnchor.constraint(equalTo: retryButton.heightAnchor)
            ])
        case .cancel:
            NSLayoutConstraint.activate([
                cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                cancelButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3)
            ])
        }
    }
}
