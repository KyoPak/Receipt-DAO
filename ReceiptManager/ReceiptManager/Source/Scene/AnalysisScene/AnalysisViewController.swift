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
    private let monthInfoLable = UILabel(font: .systemFont(ofSize: 20, weight: .medium))
    private let monthInfoAmountLabel = UILabel(font: .systemFont(ofSize: 25, weight: .bold))
    private let monthInfoCountLabel = UILabel(font: .systemFont(ofSize: 20, weight: .medium))
    
    private let ratingInfoView = UIView()
    private let ratingLabel = UILabel(font: .systemFont(ofSize: 20, weight: .medium))
    
    private let payTypeRatingView = PayTypeRatingView()
    
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
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Reactor Bind
extension AnalysisViewController {
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
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.todayButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: AnalysisViewReactor) {
        reactor.state.map { $0.dateToShow }
            .map { DateFormatter.string(from: $0) }
            .bind(to: monthControlView.monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dateToShow }
            .map { DateFormatter.string(from: $0, ConstantText.dateFormatOnlyMonth.localize()) }
            .map { ConstantText.monthExpenseText.localized(with: $0) }
            .bind(to: monthInfoLable.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state.map { $0.totalAmount },
            reactor.state.map { (Currency(rawValue: $0.currency) ?? .KRW).description }
        )
        .map { $0 + $1 }
        .bind(to: monthInfoAmountLabel.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.totalCount }
            .map { String($0) }
            .map { ConstantText.totalCountText.localized(with: $0) }
            .bind(to: monthInfoCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.rate }
            .withUnretained(self)
            .bind { (owner, rate) in
                switch rate {
                case .increase(_):
                    owner.updateRatingLabel(with: rate.rateText, color: ConstantColor.mainColor)
                    
                case .decrease(_):
                    owner.updateRatingLabel(with: rate.rateText, color: ConstantColor.subColor)
                    
                case .equal:
                    owner.ratingLabel.text = ConstantText.ratingEqual.localize()
                    
                case .noData:
                    owner.ratingLabel.text = ""
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state.map { $0.cashCount },
            reactor.state.map { $0.cardCount }
        )
        .withUnretained(self)
        .bind { (owner, counts) in
            owner.payTypeRatingView.isHidden = counts.0 + counts.1 == .zero
            owner.payTypeRatingView.caseValues = [counts.0, counts.1]
            owner.payTypeRatingView.setNeedsDisplay()
        }
        .disposed(by: disposeBag)
    }
}

extension AnalysisViewController {
    private func updateRatingLabel(with target: String, color: UIColor?) {
        ratingLabel.text = ConstantText.ratingFullText.localized(with: target)
        ratingLabel.setMutableFontColor(
            target: target,
            font: .systemFont(ofSize: 20, weight: .bold),
            color: color
        )
    }
}

// MARK: - UI Constraint
extension AnalysisViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHierarchy() {
        [monthInfoLable, monthInfoAmountLabel, monthInfoCountLabel]
            .forEach(monthInfoView.addSubview(_:))
        ratingInfoView.addSubview(ratingLabel)
        
        [navigationBar, monthControlView, monthInfoView, ratingInfoView, payTypeRatingView]
            .forEach(view.addSubview(_:))
    }
    
    private func setupProperties() {
        view.backgroundColor = ConstantColor.backGroundColor
        
        monthInfoView.backgroundColor = ConstantColor.cellColor
        monthInfoView.layer.cornerRadius = 10
        monthInfoAmountLabel.textColor = ConstantColor.mainColor
        
        ratingInfoView.backgroundColor = ConstantColor.backGroundColor
        ratingLabel.numberOfLines = 0
        
        payTypeRatingView.backgroundColor = ConstantColor.cellColor
        payTypeRatingView.layer.cornerRadius = 10
        payTypeRatingView.clipsToBounds = true
        
        [navigationBar, monthControlView, monthInfoView, ratingInfoView, payTypeRatingView].forEach {
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
            monthInfoView.heightAnchor.constraint(equalToConstant: 130),
            
            monthInfoLable.topAnchor.constraint(equalTo: monthInfoView.topAnchor, constant: 15),
            monthInfoLable.leadingAnchor.constraint(equalTo: monthInfoView.leadingAnchor, constant: 15),
            
            monthInfoAmountLabel.topAnchor.constraint(equalTo: monthInfoLable.topAnchor, constant: 30),
            monthInfoAmountLabel.leadingAnchor.constraint(equalTo: monthInfoLable.leadingAnchor),
            
            monthInfoCountLabel.leadingAnchor.constraint(equalTo: monthInfoLable.leadingAnchor),
            monthInfoCountLabel.bottomAnchor.constraint(equalTo: monthInfoView.bottomAnchor, constant: -10),
            
            ratingInfoView.topAnchor.constraint(equalTo: monthInfoView.bottomAnchor, constant: 10),
            ratingInfoView.leadingAnchor.constraint(equalTo: monthInfoView.leadingAnchor),
            ratingInfoView.trailingAnchor.constraint(equalTo: monthInfoView.trailingAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: ratingInfoView.topAnchor, constant: 15),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingInfoView.leadingAnchor, constant: 15),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingInfoView.trailingAnchor, constant: -15),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingInfoView.bottomAnchor, constant: -15),
            
            payTypeRatingView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
            payTypeRatingView.leadingAnchor.constraint(equalTo: monthInfoView.leadingAnchor),
            payTypeRatingView.trailingAnchor.constraint(equalTo: monthInfoView.trailingAnchor),
            payTypeRatingView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
