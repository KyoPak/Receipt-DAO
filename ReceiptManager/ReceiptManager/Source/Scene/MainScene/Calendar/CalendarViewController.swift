//
//  CalendarViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import UIKit

final class CalendarViewController: UIViewController {
    
    // UI Properties
    
    private let headerView = UIView()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronLeft), for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronRight), for: .normal)
        return button
    }()
    
    private let currentButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.today.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = ConstantColor.cellColor
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let calendarCollectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIConstraint
extension CalendarViewController {
    private func configureWeekLabel() {
        let dayOfTheWeek = ["일", "월", "화", "수", "목", "금", "토"]
        
        for dayIndex in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[dayIndex]
            label.textAlignment = .center
            self.weekStackView.addArrangedSubview(label)
            
            if dayIndex == 0 {
                label.textColor = ConstantColor.favoriteColor
            } else if dayIndex == 6 {
                label.textColor = ConstantColor.registerColor
            }
        }
    }
    
    private func setupHierarchy() {
        [headerView, weekStackView, calendarCollectionView].forEach(view.addSubview(_:))
        [monthLabel, previousButton, nextButton, currentButton].forEach(headerView.addSubview(_:))
    }
    
    private func setupProperties() {
        configureWeekLabel()
        view.backgroundColor = ConstantColor.backGroundColor
        calendarCollectionView.backgroundColor = ConstantColor.backGroundColor
        
        [headerView, weekStackView, calendarCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 40),
            previousButton.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -5),
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 45),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 5),
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            currentButton.widthAnchor.constraint(equalToConstant: 60),
            currentButton.heightAnchor.constraint(equalToConstant: 30),
            currentButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            currentButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            weekStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            weekStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 5),
            weekStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -5),
            
            calendarCollectionView.topAnchor.constraint(equalTo: weekStackView.bottomAnchor),
            calendarCollectionView.leadingAnchor.constraint(equalTo: weekStackView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: weekStackView.trailingAnchor),
            calendarCollectionView.heightAnchor.constraint(
                equalTo: calendarCollectionView.widthAnchor, multiplier: 1.5
            ),
        ])
    }
}
