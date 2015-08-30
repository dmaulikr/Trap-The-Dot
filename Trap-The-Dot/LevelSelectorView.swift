//
//  LevelSelectorView.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/27/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

class LevelSelectorView: UIView {
    let titleLabel: UILabel
    let levelContainerStack: UIStackView
    
    init(title: String, levelCount: Int) {
        
        titleLabel = UILabel()
        titleLabel.text = title
        levelContainerStack = UIStackView()
        super.init(frame: CGRectZero)
        
        self.addSubviews([titleLabel, levelContainerStack])
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.top.equalTo(self).offset(5)
        }
        levelContainerStack.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(5)
            make.top.equalTo(titleLabel).offset(5)
        }
        
        if levelCount == 1 {
            
        } else {
            for _ in 0..<levelCount {
//                levelContainerStack
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
