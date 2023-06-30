//
//  Scene.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

enum Scene {
    case main(MainViewModel)
    case list(ListViewModel)
    case favorite(FavoriteListViewModel)
    case compose(ComposeViewModel)
    case detail(DetailViewModel)
    case large(LargeImageViewModel)
    case selectImage(SelectImageViewModel)
    case setting(SettingViewModel)
}

extension Scene {
    func instantiate() -> UIViewController {
        switch self {
        case .main(let mainViewModel):
            let viewController = MainViewController()
            viewController.bind(viewModel: mainViewModel)
            
            return viewController
        case .list(let listViewModel):
            let viewController = ListViewController()
            viewController.bind(viewModel: listViewModel)
            
            return viewController
        case .favorite(let favoriteViewModel):
            let viewController = FavoriteListViewController()
            viewController.bind(viewModel: favoriteViewModel)
            
            return viewController
        case .compose(let composeViewModel):
            let viewController = ComposeViewController()
            viewController.bind(viewModel: composeViewModel)

            return viewController
        case .detail(let detailViewModel):
            let viewController = DetailViewController()
            viewController.bind(viewModel: detailViewModel)
            
            return viewController
        case .large(let largeImageViewModel):
            let viewController = LargeImageViewController()
            viewController.bind(viewModel: largeImageViewModel)
            
            return viewController
        case .selectImage(let selectImageViewModel):
            let viewController = SelectImageViewController()
            viewController.bind(viewModel: selectImageViewModel)
            
            return viewController
        case .setting(let settingViewModel):
            let viewController = SettingViewController()
            viewController.bind(viewModel: settingViewModel)
            
            return viewController
        }
    }
}
