//
//  LargeImageViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/18.
//

import UIKit
import RxCocoa
import RxSwift

final class LargeImageViewController: UIViewController {
    
    // Properties
    private var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: ConstantImage.xmark), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        setupHierarchy()
        setupConstraints()
    }
    
    // Initializer
    
    init(data: Data) {
        super.init(nibName: nil, bundle: nil)
        setupProperties(data: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindView() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstrinat
extension LargeImageViewController {
    private func setupProperties(data: Data) {
        imageView.image = UIImage(data: data)
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .black
    }
    
    private func setupHierarchy() {
        [closeButton, imageView].forEach(view.addSubview(_:))
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        
        closeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        closeButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
