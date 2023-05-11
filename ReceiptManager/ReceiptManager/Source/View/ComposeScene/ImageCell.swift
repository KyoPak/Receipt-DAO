//
//  ImageCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

protocol UploadImageCellDelegate: AnyObject {
    func uploadImageCell(_ isShowPicker: Bool)
}

final class ImageCell: UICollectionViewCell {
    weak var buttonDelegate: UploadImageCellDelegate?

    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        return stackView
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

// MARK: - Create View
extension ImageCell {
    func createButton() {
        let button = UIButton()
        button.tintColor = ConstantColor.registerColor
        button.backgroundColor = .lightGray
        button.setImage(UIImage(systemName: "photo.circle"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        imageStackView.addArrangedSubview(button)
    }
    
    func createImageView(data: Data) {
        let imageView = UIImageView(image: UIImage(data: data))
        imageView.contentMode = .scaleToFill
    
        imageStackView.addArrangedSubview(imageView)
    }
}

// MARK: - Action
extension ImageCell {
    @objc func addButtonTapped() {
        buttonDelegate?.uploadImageCell(true)
    }
}

// MARK: - Constraints
extension ImageCell {
    private func setupView() {
        contentView.addSubview(imageStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension ImageCell: CellReuseIdentifiable { }
