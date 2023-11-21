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
    
    // Properties
    
    private let disposeBag = DisposeBag()
    private let itemTappedSubject = PublishSubject<Int>()
    private let registerButtonSubject = PublishSubject<Void>()
    
    var itemTapped: Observable<Int> { return itemTappedSubject.asObservable() }
    var registerButtonTapped: Observable<Void> { return registerButtonSubject.asObservable() }
    
    // UI Properties
    
    private let mainItem = CustomItemView(with: .main, index: 0)
    private let bookmarkItem = CustomItemView(with: .bookmark, index: 1)
//    private let settingItem = CustomItemView(with: .setting, index: 2)
    
    private lazy var customItemViews: [CustomItemView] = [mainItem, bookmarkItem]
    
    private let registerItem: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        return imageView
    }()
        
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
        [mainItem, bookmarkItem, registerItem].forEach { self.addArrangedSubview($0) }
    }
    
    private func setupProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fillEqually
        alignment = .center
        
        backgroundColor = .label
        layer.cornerRadius = 20
        
        customItemViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
        
        registerItem.translatesAutoresizingMaskIntoConstraints = false
        registerItem.contentMode = .scaleAspectFit
        registerItem.clipsToBounds = true
        registerItem.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.index == index }
        itemTappedSubject.onNext(index)
    }
    
    //MARK: - Bindings
    private func bind() {
        mainItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.mainItem.animateClick {
                    self.selectItem(index: self.mainItem.index)
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
  
        registerItem.rx.tapGesture()
            .when(.recognized)
            .bind { _ in
                self.registerButtonSubject.onNext(Void())
            }
            .disposed(by: disposeBag)
//
//        settingItem.rx.tapGesture()
//            .when(.recognized)
//            .bind { [weak self] _ in
//                guard let self = self else { return }
//                self.settingItem.animateClick {
//                    self.selectItem(index: self.settingItem.index)
//                }
//            }
//            .disposed(by: disposeBag)
    }
}
