//
//  Theme.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/31/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let thirdColor: UIColor
    let primaryBackgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    
    static let mainTheme = Theme(
        primaryColor: UIColor.yellowColor(),
        secondaryColor: UIColor(red: 0, green: 0.59765625, blue: 0.796875, alpha: 1.0),
        thirdColor: UIColor.darkGrayColor(),
        primaryBackgroundColor: UIColor.lightGrayColor(),
        secondaryBackgroundColor: UIColor(red: 0.666667, green: 0.666667, blue: 0.633333, alpha: 1.0)
    )
    
    static var currentTheme: Theme {
        return mainTheme
    }
}