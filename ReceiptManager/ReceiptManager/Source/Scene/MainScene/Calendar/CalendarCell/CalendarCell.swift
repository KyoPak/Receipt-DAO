//
//  CalendarCell.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CalendarCell: UICollectionViewCell, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let dayLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 15))
    private let countLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 13))
    private let amountLabel = UILabel(text: "", font: .boldSystemFont(ofSize: 13))
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupProperties()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.textColor = .label
    }

    func bind(reactor: CalendarCellReactor) {
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension CalendarCell {
    private func bindState(_ reactor: CalendarCellReactor) {
        reactor.state
            .bind { self.setupData(
                day: $0.day,
                count: $0.count,
                amount: $0.amount,
                currencyIndex: $0.currencyIndex
            )}
            .disposed(by: disposeBag)
    }
    
    func setupData(day: String, count: String, amount: String, currencyIndex: Int) {
        dayLabel.text = day
        countLabel.text = count == "" ? "" : count + ConstantText.caseText.localize()
        
        if amount == "" {
            amountLabel.text = ""
        } else {
            amountLabel.text = amount + (Currency(rawValue: currencyIndex) ?? .KRW).description
        }
    }
    
    func setupWeekendColor(indexPath: Int) {
        if indexPath % 7 == 0 { dayLabel.textColor = ConstantColor.favoriteColor }
        if (indexPath + 1) % 7 == 0 { dayLabel.textColor = ConstantColor.registerColor }
    }
}

// MARK: - UI Constraints
extension CalendarCell {
    private func setupHierarchy() {
        [dayLabel, countLabel, amountLabel].forEach(addSubview(_:))
    }
    
    private func setupProperties() {
        layer.borderColor = ConstantColor.cellColor.cgColor
        layer.borderWidth = 1
        amountLabel.textColor = ConstantColor.favoriteColor
        amountLabel.numberOfLines = 1
        amountLabel.textAlignment = .right
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.1
        dayLabel.textAlignment = .left
        
        [dayLabel, countLabel, amountLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    private func setupContraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 1),
            dayLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -4),
            
            countLabel.bottomAnchor.constraint(equalTo: amountLabel.topAnchor, constant: 3),
            countLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3),
            
            amountLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 3),
            amountLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -5),
            amountLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3)
        ])
    }
}

extension CalendarCell: CellReuseIdentifiable { }
