//
//  TTDGame.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/26/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation

enum NodeType {
    case Dot
    case Road
    case Police
}

struct NodeIndex: CustomStringConvertible, Equatable {
    var line: Int
    var column: Int
    
    var description: String {
        return "line: \(line), column: \(column)"
    }
    
    var roundNodeIndexs: [NodeIndex] {
        let left = NodeIndex(line: line, column: column - 1)
        let topLeft = NodeIndex(line: line - 1, column: column - (line + 1) % 2)
        let topRight = NodeIndex(line: line - 1, column: column + line % 2)
        let right = NodeIndex(line: line, column: column + 1)
        let bottomRight = NodeIndex(line: line + 1, column: column + line % 2)
        let bottomLeft = NodeIndex(line: line + 1, column: column - (line + 1) % 2)
        return [left, topLeft, topRight, right, bottomRight, bottomLeft]
    }
}

func ==(lhs: NodeIndex, rhs: NodeIndex) -> Bool {
    return lhs.line == rhs.line && lhs.column == rhs.column
}

class TTDGame {
    var gameData: [[NodeType]]
    var dotIndex: NodeIndex
    var lines: Int
    var columns: Int
    var reachablePolices: [NodeIndex]
    
    init(lines: Int, columns: Int) {
        (self.lines, self.columns) = (lines, columns)
        dotIndex = NodeIndex(line: lines / 2, column: columns / 2)
        reachablePolices = [NodeIndex]()
        let lineData = [NodeType](count: columns, repeatedValue: .Road)
        gameData = [[NodeType]](count: lines, repeatedValue: lineData)
    }
    
    func initData(var policeCount: Int = 0) {
        for (line, lineData) in gameData.enumerate() {
            for (column, _) in lineData.enumerate() {
                gameData[line][column] = .Road
            }
        }
        
        dotIndex = NodeIndex(line: lines / 2, column: columns / 2)
        gameData[dotIndex.line][dotIndex.column] = .Dot
        
        if policeCount == 0 {
            policeCount = Int(arc4random_uniform(20)) + 5
        } else if policeCount >= lines * columns {
            policeCount = lines * columns - 1
        }
        
        for i in 0..<policeCount {
            let index = Int(arc4random_uniform(UInt32(lines * columns - 1 - i)))
            var line = index / columns
            var column = index % columns
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
    
    func checkIndexValid(index: NodeIndex) -> Bool {
        if index.line >= 0 && index.column >= 0 && gameData.count > index.line && gameData[0].count > index.column {
            return true
        }
        return false
    }
    
    func searchNext() -> NodeIndex? {
        var queue = [NodeIndex]()
        var nextIndexs = [[NodeIndex]]()
        var hasUsed = [[Bool]]()
        reachablePolices.removeAll()
        
        for line in gameData {
            var usedLine = [Bool]()
            var lineNextIndex = [NodeIndex]()
            for _ in line {
                usedLine.append(false)
                lineNextIndex.append(dotIndex)
            }
            hasUsed.append(usedLine)
            nextIndexs.append(lineNextIndex)
        }
        
        let randomSort = { (a: [NodeIndex]) -> [NodeIndex] in
            guard a.count > 0 else {
                return a
            }
            let s = Int(arc4random_uniform(UInt32(a.count)))
            var newArray = [NodeIndex]()
            for i in a[s..<a.count] {
                newArray.append(i)
            }
            for i in a[0..<s] {
                newArray.append(i)
            }
            return newArray
        }
        
        var nextIndex: NodeIndex?
        
        let roundIndexs = randomSort(dotIndex.roundNodeIndexs)
        for i in roundIndexs {
            if !checkIndexValid(i) {
                return i
            }
            if gameData[i.line][i.column] == NodeType.Road {
                queue.append(i)
                hasUsed[i.line][i.column] = true
                nextIndexs[i.line][i.column] = i
            } else if gameData[i.line][i.column] == .Police {
                reachablePolices.append(i)
                hasUsed[i.line][i.column] = true
            }
        }
        
        while let index = queue.first where nextIndex == nil {
            let roundIndexs = randomSort(index.roundNodeIndexs)
            for i in roundIndexs {
                if !checkIndexValid(i) {
                    nextIndex = nextIndexs[index.line][index.column]
                    break
                }
                if !hasUsed[i.line][i.column] {
                    if gameData[i.line][i.column] == .Road {
                        queue.append(i)
                        nextIndexs[i.line][i.column] = nextIndexs[index.line][index.column]
                    } else if gameData[i.line][i.column] == .Police {
                        reachablePolices.append(i)
                    }
                    hasUsed[i.line][i.column] = true
                }
            }
            queue.removeFirst()
        }
        return nextIndex
    }
    
    func getCircleSortedPolices() -> [NodeIndex]? {
        let lineIsInCircle = Array<Bool>(count: gameData[0].count, repeatedValue: false)
        var hasInCircle = Array<[Bool]>(count: gameData.count, repeatedValue: lineIsInCircle)
        
        var count = 0
        hasInCircle[reachablePolices[0].line][reachablePolices[0].column] = true
        while count < reachablePolices.count {
            let policeNodeIndex = reachablePolices[count]
            var hasNext = false
            let roundNodeIndexs = policeNodeIndex.roundNodeIndexs
            for roundNodeIndex in roundNodeIndexs {
                if let indexInPolices = reachablePolices.indexOf(roundNodeIndex)?.value {
                    let indexInPolices = Int(indexInPolices)
                    if indexInPolices <= count - 5 { // circle perhaps found
                        var (hasTop, hasBottom, hasLeft, hasRight) = (false, false, false, false)
                        for index in reachablePolices[indexInPolices...count] {
                            if (index.line == dotIndex.line && index.column < dotIndex.column) {
                                hasLeft = true
                            } else if (index.line == dotIndex.line && index.column > dotIndex.column) {
                                hasRight = true
                            }  else if (index.line < dotIndex.line && index.column == dotIndex.column) {
                                hasTop = true
                            }  else if (index.line > dotIndex.line && index.column == dotIndex.column) {
                                hasBottom = true
                            }
                        }
                        if hasTop && hasBottom && hasLeft && hasRight {
                            return Array(reachablePolices[indexInPolices...count])
                        } else {
                            hasInCircle[roundNodeIndex.line][roundNodeIndex.column] = true
                        }
                    } else if indexInPolices >= count + 1 {
                        reachablePolices[indexInPolices] = reachablePolices[count + 1]
                        reachablePolices[count + 1] = roundNodeIndex
                        hasInCircle[roundNodeIndex.line][roundNodeIndex.column] = true
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
                    let topNodeIndex = reachablePolices[top]
                    let roundNodeIndexs = topNodeIndex.roundNodeIndexs
                    for roundNodeIndex in roundNodeIndexs {
                        if let indexInPolices = reachablePolices.indexOf(roundNodeIndex)?.value {
                            let indexInPolices = Int(indexInPolices)
                            if !hasInCircle[roundNodeIndex.line][roundNodeIndex.column] {
                                reachablePolices[indexInPolices] = reachablePolices[top + 1]
                                reachablePolices[top + 1] = roundNodeIndex
                                hasInCircle[roundNodeIndex.line][roundNodeIndex.column] = true
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