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
    case favoriteList(FavoriteListViewModel)
    case compose(ComposeViewModel)
    case detail(DetailViewModel)
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
        case .favoriteList(let favoriteViewModel):
            let viewController = FavoriteListViewController()
            viewController.bind(viewModel: favoriteViewModel)
            
            return viewController
        case .compose(let composeViewModel):
            let viewController = ComposeViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            
            viewController.bind(viewModel: composeViewModel)
            navigation.modalPresentationStyle = .fullScreen
            return navigation
        case .detail(let detailViewModel):
            let viewController = DetailViewController()
            viewController.bind(viewModel: detailViewModel)
            
            return viewController
        }
    }
}
