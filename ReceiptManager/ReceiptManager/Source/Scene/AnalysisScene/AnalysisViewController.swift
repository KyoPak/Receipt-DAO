//
//  AnalysisViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/7/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class AnalysisViewController: UIViewController, View {
    
    // Properties
    
    var disposeBag = DisposeBag()
    weak var coordinator: AnalysisViewCoordinator?
    
    // UI Properties
    
    private let navigationBar = CustomNavigationBar(title: ConstantText.analysisTitle.localize())
    private let monthControlView = MonthControlView()
    
    private let monthInfoView = UIView()
    private let monthAmountLabel = UILabel(font: .systemFont(ofSize: 15, weight: .bold))
    private let monthAmountCountLabel = UILabel(font: .systemFont(ofSize: 15, weight: .bold))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupNavigationBar()
        setupProperties()
        setupConstraints()
    }
    
    // Initializer
    
    init(reactor: AnalysisViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: AnalysisViewReactor) {
        bindView()
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension AnalysisViewController {
    private func bindView() {
        
    }
    
    private func bindAction(_ reactor: AnalysisViewReactor) {
        monthControlView.previousButton.rx.tap
            .map { Reactor.Action.previoutMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthControlView.nextButton.rx.tap
            .map { Reactor.Action.nextMonthButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthControlView.currentButton.rx.tap
            .map { Reactor.Action.todayButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: AnalysisViewReactor) {
        reactor.state.map { $0.dateToShow }
            .map { DateFormatter.string(from: $0) }
            .bind(to: monthControlView.monthLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - UIConstraint
extension AnalysisViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHierarchy() {
        [navigationBar, monthControlView, monthInfoView].forEach(view.addSubview(_:))
        [monthAmountLabel, monthAmountCountLabel].forEach(monthInfoView.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        [navigationBar, monthControlView, monthInfoView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            monthControlView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            monthControlView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            monthControlView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            monthControlView.heightAnchor.constraint(equalToConstant: 50),
            
            monthInfoView.topAnchor.constraint(equalTo: monthControlView.bottomAnchor, constant: 10),
            monthInfoView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            monthInfoView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            monthInfoView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
