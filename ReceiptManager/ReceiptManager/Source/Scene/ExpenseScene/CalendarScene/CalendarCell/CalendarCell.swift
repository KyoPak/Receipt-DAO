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

final class CalendarCell: UIBaseCollectionViewCell, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let dayView = UIView()
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
        dayView.layer.cornerRadius = .zero
        dayView.backgroundColor = ConstantColor.backGroundColor
        backgroundColor = ConstantColor.backGroundColor
    }

    func bind(reactor: CalendarCellReactor) {
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension CalendarCell {
    private func bindState(_ reactor: CalendarCellReactor) {
        reactor.state
            .withUnretained(self)
            .bind { (owner, state) in
                owner.setupData(
                    day: state.day,
                    count: state.count,
                    amount: state.amount,
                    isToday: state.isToday,
                    currencyIndex: state.currencyIndex
                )}
            .disposed(by: disposeBag)
    }
    
    func setupData(day: String, count: String, amount: String, isToday: Bool, currencyIndex: Int) {
        dayLabel.text = day
        countLabel.text = count == "" ? "" : count + ConstantText.caseText.localize()
        
        if amount == "" {
            amountLabel.text = ""
        } else {
            amountLabel.text = amount + (Currency(rawValue: currencyIndex) ?? .KRW).sign
        }
        
        setupTodayColor(isToday)
    }
    
    func setupWeekendColor(indexPath: Int) {
        if indexPath % 7 == 0 { dayLabel.textColor = ConstantColor.mainColor }
        if (indexPath + 1) % 7 == 0 { dayLabel.textColor = ConstantColor.subColor }
    }
    
    func setupTodayColor(_ isToday: Bool) {
        if isToday {
            dayView.layer.cornerRadius = Constant.dayViewWidth / 2
            dayView.backgroundColor = .label
            dayLabel.textColor = ConstantColor.backGroundColor
            backgroundColor = .systemGray6
        }
    }
}

// MARK: - UI Constraints
extension CalendarCell {
    private func setupHierarchy() {
        dayView.addSubview(dayLabel)
        [dayView, countLabel, amountLabel].forEach(addSubview(_:))
    }
    
    private func setupProperties() {
        layer.borderColor = ConstantColor.cellColor.cgColor
        layer.borderWidth = 1
        amountLabel.textColor = ConstantColor.mainColor
        amountLabel.numberOfLines = 1
        amountLabel.textAlignment = .left
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.1
        dayLabel.textAlignment = .center
        
        [dayView, countLabel, amountLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    private func setupContraints() {
        let safeArea = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dayView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 3),
            dayView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 3),
            dayView.widthAnchor.constraint(equalToConstant: Constant.dayViewWidth),
            dayView.heightAnchor.constraint(equalTo: dayView.widthAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: dayView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: dayView.centerYAnchor),
            
            countLabel.bottomAnchor.constraint(equalTo: amountLabel.topAnchor, constant: 3),
            countLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3),
            
            amountLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 3),
            amountLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -3),
            amountLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3)
        ])
    }
}

extension CalendarCell {
    private enum Constant {
        static let dayViewWidth: CGFloat = 22
    }
}

extension CalendarCell: CellReuseIdentifiable { }
