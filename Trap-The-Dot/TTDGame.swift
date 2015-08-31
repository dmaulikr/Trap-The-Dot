//
//  TTDGame.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/26/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation

enum GameMode {
    case Random
    case Easy
    case Hard
    
    var title: String {
        switch self {
        case .Random:
            return "随机模式"
        case .Easy:
            return "简单模式"
        case .Hard:
            return "困难模式"
        }
    }
    
    var allLevels: [GameLevel] {
        switch self {
        case .Random:
            return [GameLevel(mode: .Random, level: 0)]
        case .Easy:
            var allLevels = [GameLevel]()
            for i in 0...4 {
                allLevels.append(GameLevel(mode: .Easy, level: i + 1))
            }
            return allLevels
        case .Hard:
            var allLevels = [GameLevel]()
            for i in 0...4 {
                allLevels.append(GameLevel(mode: .Hard, level: i + 1))
            }
            return allLevels
        }
    }
}

struct GameLevel: Hashable {
    var mode: GameMode
    var level: Int
    
    var policeNumber: Int {
        switch mode {
        case .Random:
            return Int(arc4random_uniform(20)) + 5
        case .Easy:
            return 40 - level * 3
        case .Hard:
            return 20 - 3 * level
        }
    }
    
    var nextLevel: GameLevel {
        var newLevel = self
        newLevel.level++
        return newLevel
    }
    
    static var currentLevel: GameLevel? = {
       return GameLevel(mode: .Random, level: 0)
    }()
    
    init(mode: GameMode, level: Int) {
        (self.mode, self.level) = (mode, level)
    }
    
    init(hashValue: Int) {
        level = hashValue % 10
        let base = hashValue - level
        if base == 10 {
            mode = .Easy
        } else  if base == 100 {
            mode = .Hard
        } else {
            mode = .Random
        }
    }
    
    var hashValue: Int {
        let base: Int
        switch mode {
        case .Random:
            base = 0
        case .Easy:
            base = 10
        case .Hard:
            base = 100
        }
        return base + level
    }
}

func ==(lhs: GameLevel, rhs: GameLevel) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

enum NodeType {
    case Dot
    case Road
    case Police
}

struct NodePosition: CustomStringConvertible, Equatable {
    var line: Int
    var column: Int
    
    var description: String {
        return "line: \(line), column: \(column)"
    }
    
    var roundNodePositions: [NodePosition] {
        let left = NodePosition(line: line, column: column - 1)
        let topLeft = NodePosition(line: line - 1, column: column - (line + 1) % 2)
        let topRight = NodePosition(line: line - 1, column: column + line % 2)
        let right = NodePosition(line: line, column: column + 1)
        let bottomRight = NodePosition(line: line + 1, column: column + line % 2)
        let bottomLeft = NodePosition(line: line + 1, column: column - (line + 1) % 2)
        return [left, topLeft, topRight, right, bottomRight, bottomLeft]
    }
}

func ==(lhs: NodePosition, rhs: NodePosition) -> Bool {
    return lhs.line == rhs.line && lhs.column == rhs.column
}

class TTDGame {
    var previousData: [[NodeType]]?
    var gameData: [[NodeType]]
    var dotPosition: NodePosition
    var lines: Int
    var columns: Int
    var reachablePolices: [NodePosition]
    
    init(lines: Int, columns: Int) {
        (self.lines, self.columns) = (lines, columns)
        dotPosition = NodePosition(line: lines / 2, column: columns / 2)
        reachablePolices = [NodePosition]()
        let lineData = [NodeType](count: columns, repeatedValue: .Road)
        gameData = [[NodeType]](count: lines, repeatedValue: lineData)
    }
    
    func initData(policeNumber: Int) {
        for (line, lineData) in gameData.enumerate() {
            for (column, _) in lineData.enumerate() {
                gameData[line][column] = .Road
            }
        }
        
        dotPosition = NodePosition(line: lines / 2, column: columns / 2)
        gameData[dotPosition.line][dotPosition.column] = .Dot
        
        for _ in 0..<policeNumber {
            let position = Int(arc4random_uniform(UInt32(lines * columns)))
            var line = position / columns
            var column = position % columns
            while gameData[line][column] != .Road {
                column += 1
                if column >= columns {
                    column = 0
                    line += 1
                    
                    if line >= lines {
                        line = 0
                    }
                }
            }
            gameData[line][column] = .Police
        }
    }
    
    func checkPositionValid(position: NodePosition) -> Bool {
        if position.line >= 0 && position.column >= 0 && gameData.count > position.line && gameData[0].count > position.column {
            return true
        }
        return false
    }
    
    func searchNext() -> NodePosition? {
        var queue = [NodePosition]()
        var nextPositions = [[NodePosition]]()
        var hasUsed = [[Bool]]()
        reachablePolices.removeAll()
        
        for line in gameData {
            var usedLine = [Bool]()
            var lineNextPosition = [NodePosition]()
            for _ in line {
                usedLine.append(false)
                lineNextPosition.append(dotPosition)
            }
            hasUsed.append(usedLine)
            nextPositions.append(lineNextPosition)
        }
        
        let randomSort = { (a: [NodePosition]) -> [NodePosition] in
            guard a.count > 0 else {
                return a
            }
            let s = Int(arc4random_uniform(UInt32(a.count)))
            var newArray = [NodePosition]()
            for i in a[s..<a.count] {
                newArray.append(i)
            }
            for i in a[0..<s] {
                newArray.append(i)
            }
            return newArray
        }
        
        var nextPosition: NodePosition?
        
        let roundPositions = randomSort(dotPosition.roundNodePositions)
        for i in roundPositions {
            if !checkPositionValid(i) {
                return i
            }
            if gameData[i.line][i.column] == NodeType.Road {
                queue.append(i)
                hasUsed[i.line][i.column] = true
                nextPositions[i.line][i.column] = i
            } else if gameData[i.line][i.column] == .Police {
                reachablePolices.append(i)
                hasUsed[i.line][i.column] = true
            }
        }
        
        while let position = queue.first where nextPosition == nil {
            let roundPositions = randomSort(position.roundNodePositions)
            for i in roundPositions {
                if !checkPositionValid(i) {
                    nextPosition = nextPositions[position.line][position.column]
                    break
                }
                if !hasUsed[i.line][i.column] {
                    if gameData[i.line][i.column] == .Road {
                        queue.append(i)
                        nextPositions[i.line][i.column] = nextPositions[position.line][position.column]
                    } else if gameData[i.line][i.column] == .Police {
                        reachablePolices.append(i)
                    }
                    hasUsed[i.line][i.column] = true
                }
            }
            queue.removeFirst()
        }
        return nextPosition
    }
    
    func getCircleSortedPolices() -> [NodePosition]? {
        let lineIsInCircle = Array<Bool>(count: gameData[0].count, repeatedValue: false)
        var hasInCircle = Array<[Bool]>(count: gameData.count, repeatedValue: lineIsInCircle)
        
        var count = 0
        hasInCircle[reachablePolices[0].line][reachablePolices[0].column] = true
        while count < reachablePolices.count {
            let policeNodePosition = reachablePolices[count]
            var hasNext = false
            let roundNodePositions = policeNodePosition.roundNodePositions
            for roundNodePosition in roundNodePositions {
                if let indexInPolices = reachablePolices.indexOf(roundNodePosition)?.value {
                    let indexInPolices = Int(indexInPolices)
                    if indexInPolices <= count - 5 { // circle perhaps found
                        var (hasTop, hasBottom, hasLeft, hasRight) = (false, false, false, false)
                        for position in reachablePolices[indexInPolices...count] {
                            if (position.line == dotPosition.line && position.column < dotPosition.column) {
                                hasLeft = true
                            } else if (position.line == dotPosition.line && position.column > dotPosition.column) {
                                hasRight = true
                            }  else if (position.line < dotPosition.line && position.column == dotPosition.column) {
                                hasTop = true
                            }  else if (position.line > dotPosition.line && position.column == dotPosition.column) {
                                hasBottom = true
                            }
                        }
                        if hasTop && hasBottom && hasLeft && hasRight {
                            return Array(reachablePolices[indexInPolices...count])
                        } else {
                            hasInCircle[roundNodePosition.line][roundNodePosition.column] = true
                        }
                    } else if indexInPolices >= count + 1 {
                        reachablePolices[indexInPolices] = reachablePolices[count + 1]
                        reachablePolices[count + 1] = roundNodePosition
                        hasInCircle[roundNodePosition.line][roundNodePosition.column] = true
                        hasNext = true
                        count += 1
                        break
                    }
                }
            }
            if (!hasNext) {
                var isDeathRoad = true
                var top = count
                while (top > 0) {
                    top -= 1;
                    let topNodePosition = reachablePolices[top]
                    let roundNodePositions = topNodePosition.roundNodePositions
                    for roundNodePosition in roundNodePositions {
                        if let indexInPolices = reachablePolices.indexOf(roundNodePosition)?.value {
                            let indexInPolices = Int(indexInPolices)
                            if !hasInCircle[roundNodePosition.line][roundNodePosition.column] {
                                reachablePolices[indexInPolices] = reachablePolices[top + 1]
                                reachablePolices[top + 1] = roundNodePosition
                                hasInCircle[roundNodePosition.line][roundNodePosition.column] = true
                                isDeathRoad = false
                                break
                            }
                        }
                    }
                    if (!isDeathRoad) {
                        count = top + 1
                        break
                    }
                }
                if (isDeathRoad) {
                    count += 1
                }
            }
        }
        return nil
    }
}