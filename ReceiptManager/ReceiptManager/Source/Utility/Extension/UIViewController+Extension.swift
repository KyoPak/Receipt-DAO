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
        
        let pasteButton = UIBarButtonItem(
            image: UIImage(systemName: ConstantImage.pasteText),
            style: .done,
            target: self,
            action: #selector(pasteText)
        )
        
        doneButton.tintColor = .label
        pasteButton.tintColor = .label
        toolbar.setItems([flexSpace, pasteButton, doneButton], animated: false)
        
        if let textView = textView as? UITextView {
            textView.inputAccessoryView = toolbar
        } else if let textField = textView as? UITextField {
            textField.inputAccessoryView = toolbar
        }
    }
    
    @objc func keyboardDone() {
        view.endEditing(true)
    }
    
    @objc func pasteText() {
        if let clipboardText = UIPasteboard.general.string {
            
            if let textView = view.currentFirstResponder() as? UITextView {
                textView.insertText(clipboardText)
            } else if let textField = view.currentFirstResponder() as? UITextField {
                textField.insertText(clipboardText)
            }
        }
        
        view.endEditing(true)
    }
}

// Find Current Focus View
extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder { return self }
        
        for view in subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}
