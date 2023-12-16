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

// MARK: - ToolBar
extension UIViewController {
    func createKeyboardToolBar(textView: UITextInput) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: ConstantImage.keyboardDown),
            style: .done,
            target: self,
            action: #selector(keyboardDone)
        )
        
        doneButton.tintColor = .label
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        if let textView = textView as? UITextView {
            textView.inputAccessoryView = toolbar
        } else if let textField = textView as? UITextField {
            textField.inputAccessoryView = toolbar
        }
    }
    
    @objc func keyboardDone() {
        view.endEditing(true)
    }
}
