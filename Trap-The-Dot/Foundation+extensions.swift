//
//  Foundation+extensions.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/28/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation

class Wrapper<T>: NSObject {
    
    var wrappedValue: T
    
    init(theValue: T) {
        wrappedValue = theValue
        super.init()
    }
}
