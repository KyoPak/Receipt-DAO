//
//  Scene.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

enum Scene {
    case list(ListViewModel)
    case compose(ComposeViewModel)
    case detail(DetailViewModel)
    case large(LargeImageViewModel)
    case selectImage(SelectImageViewModel)
}

extension Scene {
    func instantiate() -> UIViewController {
        switch self {
        case .list(let listViewModel):
            let viewController = ListViewController()
            viewController.bind(viewModel: listViewModel)
            
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
        }
    }
}
