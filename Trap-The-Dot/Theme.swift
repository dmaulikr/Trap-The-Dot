//
//  Theme.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/31/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation
import UIKit

struct Theme: Equatable {
    let name: String
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let thirdColor: UIColor
    let primaryBackgroundColor: UIColor
    
    static let mainTheme = Theme(
        name: "main",
        primaryColor: UIColor.yellowColor(),
        secondaryColor: UIColor(red: 0, green: 0.59765625, blue: 0.796875, alpha: 1.0),
        thirdColor: UIColor.darkGrayColor(),
        primaryBackgroundColor: UIColor.lightGrayColor()
    )
    
    static let grayTheme = Theme(
        name: "gray",
        primaryColor: UIColor.whiteColor(),
        secondaryColor: UIColor.blackColor(),
        thirdColor: UIColor.darkGrayColor(),
        primaryBackgroundColor: UIColor.lightGrayColor()
    )
    
    static var currentTheme: Theme = {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentTheme") == "gray" {
            return grayTheme
        }
        return mainTheme
    }() {
        willSet {
            NSUserDefaults.standardUserDefaults().setValue(newValue.name, forKey: "currentTheme")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

func == (lhs: Theme, rhs: Theme) -> Bool {
    return lhs.name == rhs.name
}

extension Theme: Hashable {
    var hashValue: Int {
        return name.hashValue
    }
}