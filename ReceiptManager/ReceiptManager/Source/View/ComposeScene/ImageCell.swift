//
//  ImageCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

protocol CellDeletable: AnyObject {
    func deleteCell(in cell: ImageCell)
}

final class ImageCell: UICollectionViewCell {
    weak var delegate: CellDeletable?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.contentMode = .center
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        deleteButton.layer.cornerRadius = deleteButton.bounds.size.width / 2
        deleteButton.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deleteButton.isHidden = false
    }
}

extension ImageCell {
    func setupReceiptImage(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    func hiddenButton() {
        deleteButton.isHidden = true
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.deleteCell(in: self)
    }
}

// MARK: - Constraints
extension ImageCell {
    private func setupView() {
        contentView.backgroundColor = ConstantColor.cellColor
        [imageView, deleteButton].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.3),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
    }
}

extension ImageCell: CellReuseIdentifiable { }
