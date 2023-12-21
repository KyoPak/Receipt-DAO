//
//  CustomAlertController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/19/23.
//

import UIKit

import RxCocoa
import RxSwift

final class CustomAlertViewController: UIViewController {
    
    // Property
    
    weak var coordinator: AlertViewCoordinator?
    private let disposeBag = DisposeBag()
    private let dismissTap = UITapGestureRecognizer()
    private let alertTitle: BehaviorSubject<String>
    
    // UI Properties
    
    private let transparentView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.4)
        return view
    }()
    
    private let alertView: AlertView = {
        let view = AlertView()
        view.backgroundColor = ConstantColor.backGroundColor
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    // Initializer
    
    init(error: Error) {
        alertTitle = BehaviorSubject(value: error.localizedDescription)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupProperties()
        setupContraints()
        bindingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeTransparency()
    }
}

// Binding
private extension CustomAlertViewController {
    func bindingView() {
        Observable.merge([
            dismissTap.rx.event.asObservable().map { _ in },
            alertView.didTapCancelButton.asObservable().map { _ in }
        ])
        .bind { [weak self] _ in
            guard let self = self else { return }
            self.coordinator?.close(self)
        }
        .disposed(by: disposeBag)
        
        alertTitle
            .bind(to: alertView.mainLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Constraints
private extension CustomAlertViewController {
    func changeTransparency() {
        UIView.animate(withDuration: 0.1) {
            self.transparentView.alpha = 0.7
        }
    }
    
    func setupHierarchy() {
        [transparentView, alertView].forEach(view.addSubview(_:))
    }
    
    func setupProperties() {
        transparentView.alpha = .zero
        transparentView.addGestureRecognizer(dismissTap)
        transparentView.isUserInteractionEnabled = true
        [transparentView, alertView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.topAnchor),
            transparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            alertView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            alertView.heightAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.3),
            alertView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.6)
        ])
    }
}
