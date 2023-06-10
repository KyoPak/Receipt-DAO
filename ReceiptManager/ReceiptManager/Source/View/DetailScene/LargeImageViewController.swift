//
//  LargeImageViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/18.
//

import UIKit
import RxCocoa
import RxSwift

final class LargeImageViewController: UIViewController, ViewModelBindable {
    var viewModel: LargeImageViewModel?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: ConstantImage.xmark), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.closeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
    }
    
    func bindViewModel() {
        viewModel?.data
            .map { UIImage(data: $0) }
            .bind(to: imageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.closeView()
            })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UIConstrinat
extension LargeImageViewController {
    private func setupView() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .black
        [closeButton, imageView].forEach(view.addSubview(_:))
    }
    
    private func setupConstraint() {
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
