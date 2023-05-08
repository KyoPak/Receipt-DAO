//
//  CellReuseIdentifiable.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/09.
//

import Foundation

protocol CellReuseIdentifiable: AnyObject { }

extension CellReuseIdentifiable {
    static var identifier: String {
        return String.init(describing: self)
    }
}
