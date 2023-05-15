//
//  ImageCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageCell {
    func setupReceiptImage(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
}

// MARK: - Constraints
extension ImageCell {
    private func setupView() {
        contentView.backgroundColor = ConstantColor.favoriteColor
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension ImageCell: CellReuseIdentifiable { }
