//
//  OCRResultView.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/12/23.
//

import UIKit

import RxSwift

protocol OCRViewInteractable: AnyObject {
    func closeOCRView()
}

final class OCRResultView: UIView {
    
    // Properties
    
    private let disposeBag = DisposeBag()
    weak var delegate: OCRViewInteractable?
    
    // UI Properties
    
    private let infoLabel = UILabel(
        text: ConstantText.copyText.localize(),
        font: .systemFont(ofSize: 15, weight: .bold)
    )
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.close.localize(), for: .normal)
        button.backgroundColor = ConstantColor.cellColor
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.isHidden = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let scrollView = UIScrollView()
    
    private let buttonTotalStackView = UIStackView(
        subViews: [],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OCRResultView {
    @objc private func closeButtonTapped() {
        closeButton.isHidden = true
        delegate?.closeOCRView()
    }
}

// MARK: - Add Text Button Logic
extension OCRResultView {
    func setupButton(texts: [String]) {
        closeButton.isHidden = false
        removeAllSubviews(from: buttonTotalStackView)
        
        var stackView = horizentalStackView()
        var totalWidth: CGFloat = .zero
        
        for text in texts {
            let button = button(text: text)
            let titleSize = button.titleLabel?.intrinsicContentSize ?? .zero
            totalWidth += titleSize.width + 10
            
            if totalWidth >= UIScreen.main.bounds.width - 20 {
                buttonTotalStackView.addArrangedSubview(stackView)
                stackView = horizentalStackView()
                totalWidth = titleSize.width + 10
                stackView.addArrangedSubview(button)
                continue
            }
            
            stackView.addArrangedSubview(button)
        }
        
        buttonTotalStackView.addArrangedSubview(stackView)
    }
    
    private func horizentalStackView() -> UIStackView {
        return UIStackView(
            subViews: [],
            axis: .horizontal,
            alignment: .fill,
            distribution: .fillProportionally,
            spacing: 10
        )
    }
    
    private func button(text: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = ConstantColor.cellColor
        button.setTitleColor(.label, for: .normal)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        button.layer.cornerRadius = 10
        button.rx.tap
            .bind { UIPasteboard.general.string = button.titleLabel?.text }
            .disposed(by: disposeBag)
        
        return button
    }
    
    private func removeAllSubviews(from stackView: UIStackView) {
        for subview in stackView.subviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}

// MARK: - UI Constraint
extension OCRResultView: UITextFieldDelegate {
    private func setupHierarchy() {
        scrollView.addSubview(buttonTotalStackView)
        [infoLabel, closeButton, scrollView].forEach(addSubview(_:))
    }
    
    private func setupProperties() {
        backgroundColor = ConstantColor.backGroundColor
        [infoLabel, closeButton, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            infoLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            scrollView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 15),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            
            buttonTotalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            buttonTotalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            buttonTotalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            buttonTotalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            buttonTotalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}
