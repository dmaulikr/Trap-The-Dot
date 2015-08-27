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
    
    init(data: [[NodeType]]) {
        super.init(frame: CGRectZero)
        
        for line in data {
            var lineLayers = [CALayer]()
            for type in line {
                let layer = CALayer()
                layer.backgroundColor = type.color
                layer.masksToBounds = true
                layer.borderWidth = 2
                
                self.layer.addSublayer(layer)
                lineLayers.append(layer)
            }
            layers.append(lineLayers)
        }
        layoutNodeLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
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
    
    func moveDotFrom(from: NodeIndex, toIndex to: NodeIndex) {
        guard checkIndexValid(from) && checkIndexValid(to) else {
            return
        }
        
        let fromOrigin = originOfIndex(from)
        let toOrigin = originOfIndex(to)
        layers[from.line][from.column].backgroundColor = NodeType.Road.color
        let dotLayer = CALayer(layer: layers[from.line][from.column])
        dotLayer.backgroundColor = NodeType.Dot.color
        dotLayer.frame = layers[from.line][from.column].frame
        dotLayer.masksToBounds = true
        dotLayer.borderWidth = 2
        dotLayer.cornerRadius = nodeWidth / 2
        dotLayer.borderColor = (backgroundColor ?? UIColor.lightGrayColor()).CGColor
        self.layer.addSublayer(dotLayer)
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(CGPoint: dotLayer.position)
        let toPosition = CGPoint(x: dotLayer.position.x + toOrigin.x - fromOrigin.x, y: dotLayer.position.y + toOrigin.y - fromOrigin.y)
        animation.toValue = NSValue(CGPoint: toPosition)
        animation.duration = 0.5
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        CATransaction.setCompletionBlock { () -> Void in
            self.layers[to.line][to.column].backgroundColor = NodeType.Dot.color
            dotLayer.removeFromSuperlayer()
        }
        dotLayer.addAnimation(animation, forKey: "position")
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
