//
//  CalendarViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/30/23.
//

import ReactorKit

final class CalendarViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    
    // UI Properties
    
    private let weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = ConstantColor.cellColor
        return stackView
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionCellWidth = (UIScreen.main.bounds.width - 6) / 7
        let collectionCellHeight = collectionCellWidth * 1.4
        layout.itemSize = CGSize(width: collectionCellWidth, height: collectionCellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
        collectionView.backgroundColor = ConstantColor.cellColor
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: CalendarViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CalendarViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension CalendarViewController: UICollectionViewDelegate {
    private func bindView() {
        calendarCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: CalendarViewReactor) {
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.loadData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: CalendarViewReactor) {
        reactor.state.map { $0.dayInfos }
            .bind(
                to: calendarCollectionView.rx.items(
                cellIdentifier: CalendarCell.identifier, 
                cellType: CalendarCell.self)
            ) { indexPath, data, cell in
                cell.setupData(day: data.days, count: data.countOfExpense, amount: data.dayAmount)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraint
extension CalendarViewController {
    private func configureWeekLabel() {
        let dayOfTheWeek = ["일", "월", "화", "수", "목", "금", "토"]
        
        for dayIndex in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[dayIndex]
            label.font = .systemFont(ofSize: 15, weight: .semibold)
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
            weekStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            weekStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 3),
            weekStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -3),
            
            calendarCollectionView.topAnchor.constraint(equalTo: weekStackView.bottomAnchor),
            calendarCollectionView.leadingAnchor.constraint(equalTo: weekStackView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: weekStackView.trailingAnchor),
            calendarCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
