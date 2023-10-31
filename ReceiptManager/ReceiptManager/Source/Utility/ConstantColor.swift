//
//  ConstantColor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/08.
//

import UIKit

enum ConstantColor {
    static let backGroundColor = UIColor(named: "backGround")
                ?? UIColor(red: 25/255, green: 41/255, blue: 67/255, alpha: 1)
    static let favoriteColor = UIColor(named: "sub")
                ?? UIColor(red: 203/255, green: 190/255, blue: 215/255, alpha: 1)
    static let registerColor = UIColor(named: "main")
                ?? UIColor(red: 197/255, green: 235/255, blue: 167/255, alpha: 1)
    static let cellColor = UIColor(named: "cell")
                ?? UIColor(red: 36/255, green: 52/255, blue: 78/255, alpha: 1)
    static let layerColor = UIColor(named: "layer")
                ?? UIColor(red: 36/255, green: 52/255, blue: 78/255, alpha: 1)
}
