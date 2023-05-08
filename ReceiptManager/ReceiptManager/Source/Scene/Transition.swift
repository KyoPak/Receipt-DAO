//
//  Transition.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/02.
//

import Foundation

enum TransitionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
