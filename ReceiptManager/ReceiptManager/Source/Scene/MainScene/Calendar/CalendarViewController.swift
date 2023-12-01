//
//  CalendarViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import UIKit

final class CalendarViewController: UIViewController {
    
    // UI Properties
    
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
            label.font = .systemFont(ofSize: 13, weight: .semibold)
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
        [weekStackView, calendarCollectionView].forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        configureWeekLabel()
        view.backgroundColor = ConstantColor.backGroundColor
        calendarCollectionView.backgroundColor = ConstantColor.backGroundColor
        
        [weekStackView, calendarCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            weekStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            weekStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 5),
            weekStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -5),
            
            calendarCollectionView.topAnchor.constraint(equalTo: weekStackView.bottomAnchor),
            calendarCollectionView.leadingAnchor.constraint(equalTo: weekStackView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: weekStackView.trailingAnchor),
            calendarCollectionView.heightAnchor.constraint(
                equalTo: calendarCollectionView.widthAnchor, multiplier: 1.5
            )
        ])
    }
}
