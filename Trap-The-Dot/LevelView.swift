//
//  LevelView.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/29/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

class LevelView: UIView {
    
    var level = GameLevel(mode: .Random, level: 0)
    var minSteps: Int = Int.max
    
    var titleLayer: CATextLayer?
    var smallRectLayer: CAShapeLayer?

    override func drawRect(rect: CGRect) {
        if smallRectLayer == nil {
            smallRectLayer = CAShapeLayer()
            smallRectLayer!.strokeColor = Theme.currentTheme.primaryColor.CGColor
            smallRectLayer!.lineWidth = 0
            smallRectLayer!.lineCap = kCALineCapRound
            smallRectLayer!.lineJoin = kCALineJoinRound
            smallRectLayer!.fillColor = UIColor.clearColor().CGColor
            layer.addSublayer(smallRectLayer!)
        }
        
        let path = CGPathCreateMutable()
        CGPathAddRoundedRect(path, nil, CGRect(x: layer.bounds.size.width * 0.2, y: layer.bounds.size.height * 0.2, width: layer.bounds.size.width * 0.6, height: layer.bounds.size.height * 0.6), layer.bounds.size.width * 0.3, layer.bounds.size.height * 0.3)
        smallRectLayer!.path = path
        
        if titleLayer == nil {
            titleLayer = CATextLayer()
            titleLayer!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            titleLayer!.alignmentMode = kCAAlignmentCenter
            titleLayer!.foregroundColor = UIColor.whiteColor().CGColor
            titleLayer!.font = UIFont.systemFontOfSize(20)
            titleLayer!.fontSize = 20
            titleLayer!.position = CGPoint(x: layer.bounds.size.width / 2, y: layer.bounds.size.height / 2)
            titleLayer!.bounds = CGRect(x: 0, y: 0, width: 50, height: 26)
            
            layer.addSublayer(titleLayer!)
        }
        titleLayer!.string = minSteps < Int.max ? "\(minSteps)" : "?"
        
        layer.borderColor = Theme.currentTheme.primaryColor.CGColor
        layer.borderWidth = 2
        layer.cornerRadius = min(layer.bounds.size.width, layer.bounds.size.height) / 2
        layer.masksToBounds = true
    }

}
