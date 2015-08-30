//
//  GameBoardView.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

extension NodeType {
    var color: CGColor {
        switch self {
        case .Dot:
            return UIColor.blueColor().CGColor
        case .Road:
            return UIColor.darkGrayColor().CGColor
        case .Police:
            return UIColor.yellowColor().CGColor
        }
    }
}

let nodeHeightWidthRatio: CGFloat = 0.8204451193747312

class GameBoardView: UIView {
    var layers = [[CALayer]]()
    var nodeWidth: CGFloat = 0
    
    init(lines: Int, columns: Int) {
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func initGameViewWithData(data: [[NodeType]]) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        
        layers = [[CALayer]]()
        for (line, lineData) in data.enumerate() {
            var lineLayers = [CALayer]()
            for (column, type) in lineData.enumerate() {
                let layer = nodeLayerForIndex(NodeIndex(line: line, column: column), type: type)
                self.layer.addSublayer(layer)
                lineLayers.append(layer)
            }
            layers.append(lineLayers)
        }
        layoutNodeLayers()
    }
    
    func nodeLayerForIndex(index: NodeIndex, type: NodeType) -> CALayer {
        let layer = CALayer()
        layer.borderWidth = 3
        layer.backgroundColor = type.color
//        let textLayer = CATextLayer()
//        textLayer.string = "\(index.line), \(index.column)"
//        textLayer.alignmentMode = kCAAlignmentCenter
//        textLayer.foregroundColor = UIColor.whiteColor().CGColor
//        textLayer.font = UIFont.systemFontOfSize(20)
//        textLayer.fontSize = 20
//        textLayer.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//        layer.addSublayer(textLayer)
        return layer
    }
    
    func layoutNodeLayers() {
        guard layers.count > 0 else {
            return
        }
        nodeWidth = bounds.size.width / (CGFloat(layers[0].count) + 0.5)
        for (line, lineLayers) in layers.enumerate() {
            for (column, layer) in lineLayers.enumerate() {
                let xPos = (CGFloat(line % 2) * 0.5 + CGFloat(column)) * nodeWidth
                let yPos = nodeHeightWidthRatio * CGFloat(line) * nodeWidth
                
                layer.borderColor = (backgroundColor ?? UIColor.lightGrayColor()).CGColor
                layer.cornerRadius = nodeWidth / 2
                layer.frame = CGRect(x: xPos, y: yPos, width: nodeWidth, height: nodeWidth)
            }
        }
    }
    
    func indexOfPosition(position: CGPoint) -> NodeIndex? {
        for (line, lineLayers) in layers.enumerate() {
            for (column, layer) in lineLayers.enumerate() {
                let point = self.layer.convertPoint(position, toLayer: layer)
                if point.x >= 0 && point.y >= 0 && point.x < nodeWidth && point.y < nodeWidth {
                    return NodeIndex(line: line, column: column)
                }
            }
        }
        return nil
    }
    
    func changeIndexToType(index: NodeIndex, type: NodeType) {
        guard checkIndexValid(index) else {
            return
        }
        
        let layer = layers[index.line][index.column]
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = layer.backgroundColor
        animation.toValue = type.color
        animation.duration = 0.5
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        layer.addAnimation(animation, forKey: "backgroundColor")
    }
    
    func copyDotLayer(dotIndex: NodeIndex) -> CALayer {
        let dotLayer = CALayer()
        dotLayer.backgroundColor = NodeType.Dot.color
        dotLayer.frame = layers[dotIndex.line][dotIndex.column].frame
        dotLayer.borderWidth = 3
        dotLayer.cornerRadius = nodeWidth / 2
        dotLayer.borderColor = (backgroundColor ?? UIColor.lightGrayColor()).CGColor
        return dotLayer
    }
    
    func moveDotFrom(from: NodeIndex, toIndex to: NodeIndex, game: TTDGame) {
        guard checkIndexValid(from) && checkIndexValid(to) else {
            return
        }
        
        let fromOrigin = originOfIndex(from)
        let toOrigin = originOfIndex(to)
        layers[from.line][from.column].backgroundColor = NodeType.Road.color
        
        let copyedDotLayer = copyDotLayer(from)
        self.layer.addSublayer(copyedDotLayer)
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(CGPoint: copyedDotLayer.position)
        let toPosition = CGPoint(x: copyedDotLayer.position.x + toOrigin.x - fromOrigin.x, y: copyedDotLayer.position.y + toOrigin.y - fromOrigin.y)
        animation.toValue = NSValue(CGPoint: toPosition)
        animation.duration = 0.5
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        CATransaction.setCompletionBlock { () -> Void in
            if game.dotIndex == to {
                self.layers[to.line][to.column].backgroundColor = NodeType.Dot.color
            }
            copyedDotLayer.removeFromSuperlayer()
        }
        copyedDotLayer.addAnimation(animation, forKey: "position")
        CATransaction.commit()
    }
    
    func linkCirclePolices(indexes: [NodeIndex]) {
        let path = CGPathCreateMutable()
        if let first = indexes.first {
            let firstLayer = layers[first.line][first.column]
            CGPathMoveToPoint(path, nil, firstLayer.position.x, firstLayer.position.y)
            for index in indexes[1..<indexes.count] {
                let layer = layers[index.line][index.column]
                CGPathAddLineToPoint(path, nil, layer.position.x, layer.position.y)
            }
            CGPathAddLineToPoint(path, nil, firstLayer.position.x, firstLayer.position.y)
            let lineLayer = CAShapeLayer()
            lineLayer.path = path
            lineLayer.strokeColor = UIColor.orangeColor().CGColor
            lineLayer.lineWidth = nodeWidth / 5
            lineLayer.lineCap = kCALineCapRound
            lineLayer.lineJoin = kCALineJoinRound
            lineLayer.fillColor = UIColor.clearColor().CGColor
            self.layer.addSublayer(lineLayer)
        }
    }
    
    func dotEscapeTo(index: NodeIndex, from: NodeIndex, complete: ()->()) {
        let copyedDotLayer = copyDotLayer(from)
        self.layer.addSublayer(copyedDotLayer)
        layers[from.line][from.column].backgroundColor =  NodeType.Road.color
        
        // as CATransition manipulates a layer’s cached image to create visual effects, so need to wait for the layer's updating on screen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            CATransaction.begin()
            let transition = CATransition()
            transition.type = kCATransitionReveal
            transition.duration = 1.0
            transition.removedOnCompletion = true
            transition.fillMode = kCAFillModeForwards
            
            if (index.line < 0) { transition.subtype = kCATransitionFromTop }
            else if (index.line >= self.layers.count) { transition.subtype = kCATransitionFromBottom }
            else if (index.column < 0) { transition.subtype = kCATransitionFromRight }
            else { transition.subtype = kCATransitionFromLeft }
            
            CATransaction.setCompletionBlock { () -> Void in
                copyedDotLayer.removeFromSuperlayer()
                complete()
            }
            
            copyedDotLayer.backgroundColor =  NodeType.Road.color
            copyedDotLayer.addAnimation(transition, forKey: kCATransitionReveal)
            CATransaction.commit()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            layoutNodeLayers()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layoutNodeLayers()
        }
    }
    
    func checkIndexValid(index: NodeIndex) -> Bool {
        if index.line >= 0 && index.column >= 0 && layers.count > index.line && layers[0].count > index.column {
            return true
        }
        return false
    }
    
    func originOfIndex(index: NodeIndex) -> CGPoint {
        let xPos = (CGFloat(index.line % 2) * 0.5 + CGFloat(index.column)) * nodeWidth
        let yPos = nodeHeightWidthRatio * CGFloat(index.line) * nodeWidth
        return CGPoint(x: xPos, y: yPos)
    }
}
