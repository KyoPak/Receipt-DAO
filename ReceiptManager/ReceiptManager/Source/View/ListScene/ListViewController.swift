//
//  ListViewController.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class ListViewController: UIViewController, ViewModelBindable {
    var viewModel: ListViewModel?
    
    // MARK: - UIComponent
    private var headerView = UIView()
    
    private var monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private var previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronLeft), for: .normal)
        
        return button
    }()
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: ConstantImage.chevronRight), for: .normal)
        
        return button
    }()
    
    private var nowButton: UIButton = {
        let button = UIButton()
        button.setTitle(ConstantText.today.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(UIColor.label, for: .normal)
        button.backgroundColor = ConstantColor.cellColor
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableView()
        setupConstraints()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        // ViewModel Properties Binding
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.receiptList
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.currentDateRelay
            .map { date in
                return DateFormatter.string(from: date)
            }
            .asDriver(onErrorJustReturn: "")
            .drive(monthLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Receipt.self), tableView.rx.itemSelected)
            .withUnretained(self)
            .do(onNext: { (owner, data) in
                owner.tableView.deselectRow(at: data.1, animated: true)
            })
            .map { $1.0 }
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.moveDetailAction(receipt: $0)
            })
            .disposed(by: rx.disposeBag)
            
        // Button Binding
        previousButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.movePriviousAction()
            }
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveNextAction()
            }
            .disposed(by: rx.disposeBag)
        
        nowButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.viewModel?.moveNowAction()
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: ConstantText.delete.localize()
        ) { [weak self] _, _, completion in
            self?.viewModel?.deleteAction(indexPath: indexPath)
            completion(true)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] _, _, completion in
                self?.viewModel?.favoriteAction(indexPath: indexPath)
                completion(true)
            }
        )
        
        let label = UILabel(text: ConstantText.bookMark.localize(), font: .preferredFont(forTextStyle: .body))
        label.textColor = ConstantColor.cellColor
        label.backgroundColor = .systemYellow
        label.sizeToFit()
        
        favoriteAction.backgroundColor = .systemYellow
        favoriteAction.image = UIImage(view: label)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [favoriteAction])
        
        return swipeActions
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = viewModel?.dataSource[section]
        
        let string = data?.identity
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .label
        label.text = string
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 해당 방법은 HeaderView라는 식별자를 가진 View를 새로 만든다.
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "HeaderView")

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - Action
extension ListViewController {
    @objc private func registerButtonTapped() {
        viewModel?.moveRegisterAction()
    }
}

// MARK: - UIConstraint
extension ListViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ConstantColor.backGroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: ConstantText.shortRegister.localize(),
            style: .done,
            target: self,
            action: #selector(registerButtonTapped)
        )
    }
    
    private func setupView() {
        [headerView, tableView].forEach(view.addSubview(_:))
        [monthLabel, previousButton, nextButton, nowButton].forEach(headerView.addSubview(_:))
        [headerView, monthLabel, previousButton, nextButton, nowButton, tableView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.backgroundColor = ConstantColor.backGroundColor
    }
    
    private func setupTableView() {
        tableView.backgroundColor = ConstantColor.backGroundColor
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            
            monthLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            monthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 45),
            previousButton.trailingAnchor.constraint(equalTo: monthLabel.leadingAnchor, constant: -5),
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 5),
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            nowButton.widthAnchor.constraint(equalToConstant: 60),
            nowButton.heightAnchor.constraint(equalToConstant: 30),
            nowButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            nowButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
