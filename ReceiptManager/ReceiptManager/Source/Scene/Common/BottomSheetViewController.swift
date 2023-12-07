//
//  BottomSheetViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/6/23.
//

import UIKit

import RxSwift

final class BottomSheetViewController: UIViewController {
    
    // Properties
    
    private let bottomHeightRatio: Double
    private var bottomContainerViewHeightConstraint: NSLayoutConstraint?
    
    // UI Properties
    
    private let transparentView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.4)
        return view
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ConstantColor.backGroundColor
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let childController: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupContraints()
        setupGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
    
    // Initializer
    
    init(controller: UIViewController, bottomHeightRatio: Double) {
        self.childController = controller
        self.bottomHeightRatio = bottomHeightRatio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapDismiss() {
        transparentView.alpha = 1
        transparentView.backgroundColor = .clear
        
        dismiss(animated: true)
    }
}

extension BottomSheetViewController: UIGestureRecognizerDelegate {
    private func setupGesture() {
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(didTapDismiss))
        let dismissSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapDismiss))
        dismissSwipe.direction = .down
        dismissSwipe.delegate = self
        
        transparentView.addGestureRecognizer(dismissTap)
        bottomContainerView.addGestureRecognizer(dismissSwipe)
    }
}

extension BottomSheetViewController {
    private func showBottomSheet() {
        let height = view.frame.height * bottomHeightRatio
        
        bottomContainerViewHeightConstraint?.constant = height
        
        UIView.animate(withDuration: 0.1) {
            self.transparentView.alpha = 0.6
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIConstraints
extension BottomSheetViewController {
    private func setupHierarchy() {
        addChild(childController)
        bottomContainerView.addSubview(childController.view)
        [transparentView, bottomContainerView].forEach(view.addSubview(_:))
    }
    
    func setupProperties() {
        transparentView.alpha = .zero
        [transparentView, bottomContainerView, childController.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupContraints() {
        bottomContainerViewHeightConstraint = bottomContainerView.heightAnchor.constraint(equalToConstant: 0)
        guard let bottomContainerViewHeightConstraint = bottomContainerViewHeightConstraint else { return }
        
        NSLayoutConstraint.activate([
            transparentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentView.topAnchor.constraint(equalTo: view.topAnchor),
            transparentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transparentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerViewHeightConstraint,
            
            childController.view.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            childController.view.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            childController.view.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            childController.view.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
    }
}
