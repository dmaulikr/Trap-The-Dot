//
//  UIView+extensions.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(views: [UIView]) {
        for v in views {
            self.addSubview(v)
        }
    }
}