//
//  ImageRegisterCellView.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import UIKit

final class ImageRegisterCellView: UIView {
    
    // UI Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: ConstantImage.camera)?
            .withTintColor(.label).withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageRegisterCellView {
    func setupCountLabel(_ count: Int) {
        countLabel.text = "\(count - 1)/5"
    }
}

// MARK: - UI Constraints
extension ImageRegisterCellView {
    private func setupProperties() {
        [imageView, countLabel].forEach(addSubview(_:))
        backgroundColor = ConstantColor.cellColor
        clipsToBounds = true
        layer.cornerRadius = 10
        isHidden = true
    }
    
    private func setupHierarchy() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            countLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            countLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
}
