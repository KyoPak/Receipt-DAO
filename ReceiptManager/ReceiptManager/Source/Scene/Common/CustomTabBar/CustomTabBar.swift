//
//  CustomTabBar.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class CustomTabBar: UIStackView {
    private let disposeBag = DisposeBag()
    private let listItem = CustomItemView(with: .list, index: 0)
    private let bookmarkItem = CustomItemView(with: .bookmark, index: 1)
    private let settingItem = CustomItemView(with: .setting, index: 2)
    
    private lazy var customItemViews: [CustomItemView] = [listItem, bookmarkItem, settingItem]
    
    private let itemTappedSubject = PublishSubject<Int>()
    var itemTapped: Observable<Int> { return itemTappedSubject.asObservable() }
    
    init() {
        super.init(frame: .zero)
        
        setupHierarchy()
        setupProperties()
        bind()
        
        setNeedsLayout()
        layoutIfNeeded()
        selectItem(index: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        [listItem, bookmarkItem, settingItem].forEach { self.addArrangedSubview($0) }
    }
    
    private func setupProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fillEqually
        alignment = .center
        
        backgroundColor = ConstantColor.registerColor
        layer.cornerRadius = 30
        
        customItemViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
    }
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.index == index }
        itemTappedSubject.onNext(index)
    }
    
    //MARK: - Bindings
    private func bind() {
        listItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.listItem.animateClick {
                    self.selectItem(index: self.listItem.index)
                }
            }
            .disposed(by: disposeBag)
        
        bookmarkItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.bookmarkItem.animateClick {
                    self.selectItem(index: self.bookmarkItem.index)
                }
            }
            .disposed(by: disposeBag)
        
        settingItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.settingItem.animateClick {
                    self.selectItem(index: self.settingItem.index)
                }
            }
            .disposed(by: disposeBag)
    }
}
