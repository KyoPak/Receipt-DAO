//
//  Scene.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import UIKit

enum Scene {
    
    case selectImage(SelectImageViewModel)
}

extension Scene {
    func instantiate() -> UIViewController {
        switch self {
        case .selectImage(let selectImageViewModel):
            let viewController = LimitAlbumViewController()
            viewController.bind(viewModel: selectImageViewModel)
            
            return viewController
        }
    }
}
