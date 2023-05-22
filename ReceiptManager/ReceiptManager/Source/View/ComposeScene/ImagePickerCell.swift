//
//  ImagePickerCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/22.
//

import UIKit

final class ImagePickerCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override var isSelected: Bool {
        willSet {
            setSelected(newValue)
        }
    }
    
    private func setSelected(_ selected: Bool) {
        imageView.alpha = selected ? 0.5 : 1.0
        contentView.layer.borderWidth = selected ? 3 : .zero
        contentView.layer.borderColor = selected ? ConstantColor.registerColor.cgColor : UIColor.clear.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension ImagePickerCell: CellReuseIdentifiable { }
