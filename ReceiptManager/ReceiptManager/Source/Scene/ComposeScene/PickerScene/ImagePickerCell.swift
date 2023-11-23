//
//  ImagePickerCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/22.
//

import UIKit

final class ImagePickerCell: UICollectionViewCell {
    
    // UI Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.alpha = 1.0
        contentView.layer.borderWidth = .zero
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setSelected() {
        imageView.alpha = isSelected ? 0.5 : 1.0
        contentView.layer.borderWidth = isSelected ? 3 : .zero
        contentView.layer.borderColor = isSelected ?
            ConstantColor.registerColor.cgColor : UIColor.clear.cgColor
    }
    
    func setupData(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
}

// MARK: - UIConstraint
extension ImagePickerCell {
    private func setupHierarchy() {
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension ImagePickerCell: CellReuseIdentifiable { }
