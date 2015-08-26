//
//  UIViewController+extensions.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation
import SnapKit

extension UIViewController {
    func addTTDTitle() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "围住点点"
        titleLabel.font = UIFont.systemFontOfSize(32, weight: UIFontWeightSemibold)
        
        view.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(50)
            make.height.equalTo(50)
        }
        
        return titleLabel
    }
}