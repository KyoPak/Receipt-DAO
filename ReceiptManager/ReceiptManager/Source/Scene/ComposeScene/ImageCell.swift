//
//  ImageCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/11.
//

import UIKit

protocol CellInteractable: AnyObject {
    func deleteCell(in cell: ImageCell)
    func ocrCell(in cell: ImageCell)
}

final class ImageCell: UICollectionViewCell {
    
    // Properties
    
    weak var delegate: CellInteractable?
    
    // UI Properties

    private let registerView = ImageRegisterCellView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "deleteImage"), for: .normal)
        button.contentMode = .center
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var ocrButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "text.viewfinder"), for: .normal)
        button.contentMode = .center
        button.backgroundColor = ConstantColor.cellColor
        button.alpha = 0.7
        button.tintColor = .label
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(ocrButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        deleteButton.layer.cornerRadius = deleteButton.bounds.size.width / 2
        deleteButton.clipsToBounds = true
    }
    
    // Initializer
    
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
        ocrButton.isHidden = false
        registerView.isHidden = true
        imageView.isHidden = false
    }
}

extension ImageCell {
    func setupReceiptImage(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    func hiddenDeleteButton() {
        deleteButton.isHidden = true
        ocrButton.isHidden = true
    }
    
    func setupHidden(isFirstCell: Bool) {
        imageView.isHidden = isFirstCell
        registerView.isHidden = !isFirstCell
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.deleteCell(in: self)
    }
    
    @objc private func ocrButtonTapped() {
        delegate?.ocrCell(in: self)
    }
    
    func setupCountLabel(_ count: Int) {
        registerView.setupCountLabel(count)
    }
}

// MARK: - UI Constraints
extension ImageCell {
    private func setupView() {
        contentView.backgroundColor = ConstantColor.backGroundColor
        [registerView, imageView, deleteButton, ocrButton].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            registerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            registerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            registerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            registerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.3),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor),
            
            ocrButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            ocrButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            ocrButton.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.3),
            ocrButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
    }
}

extension ImageCell: CellReuseIdentifiable { }
