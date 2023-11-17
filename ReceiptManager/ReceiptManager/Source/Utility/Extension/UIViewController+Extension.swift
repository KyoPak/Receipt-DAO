//
//  UIViewController+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/27.
//

import UIKit

// MARK: - Activity View
extension UIViewController {
    func presentActivityView(datas: [Data]) {
        var imageDatas: [UIImage] = []
        
        for data in datas {
            if let image = UIImage(data: data) {
                imageDatas.append(image)
            }
        }
        
        let activiyController = UIActivityViewController(
            activityItems: imageDatas,
            applicationActivities: nil
        )
        
        activiyController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks
        ]
        
        present(activiyController, animated: true, completion: nil)
    }
}
