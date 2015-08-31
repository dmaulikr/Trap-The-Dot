//
//  TTDGameTest.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/26/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import XCTest
@testable import Trap_The_Dot

class TTDGameTest: XCTestCase {
    
    var game: TTDGame!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        game = TTDGame(lines: 9, columns: 9)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(1 == 1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInit() {
        XCTAssertEqual(game.lines, 9)
        XCTAssertEqual(game.columns, 9)
        XCTAssertEqual(game.gameData.count, 9)
        XCTAssertEqual(game.gameData[0].count, 9)
    }
    
    func testInitData() {
        game.initData(10)
        
        XCTAssertEqual(game.dotPosition, NodePosition(line: 4, column: 4))
        
        var (dotNum, roadNum, policeNum) = (0, 0, 0)
        for lineData in game.gameData {
            for type in lineData {
                switch type {
                case .Dot:
                    dotNum++
                case .Police:
                    policeNum++
                case .Road:
                    roadNum++
                }
            }
        }
        XCTAssertEqual(dotNum, 1, "dot number should be 1")
        XCTAssertEqual(roadNum, 70, "road number should be 81 - 1 - 10")
        XCTAssertEqual(policeNum, 10, "police number should be 10")
    }
    
    func testcheckPositionValid() {
        XCTAssertFalse(game.checkPositionValid(NodePosition(line: 10, column: 8)), "(line: 9, column: 8) should be invaild")
        XCTAssertFalse(game.checkPositionValid(NodePosition(line: 0, column: -1)), "(line: 0, column: -1) should be invaild")
        XCTAssertTrue(game.checkPositionValid(NodePosition(line: 0, column: 0)), "(line: 0, column: 0) should be vaild")
        XCTAssertTrue(game.checkPositionValid(NodePosition(line: 8, column: 8)), "(line: 8, column: 8) should be vaild")
    }
    
    func testSearchNextShouldReturnTheRightNextPosition() {
        game.gameData = [
            [.Police, .Police, .Police, .Police, .Road  , .Police, .Police, .Police, .Police],
            [.Police, .Road  , .Road  , .Road  , .Road  , .Police, .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Road  , .Police, .Road  , .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Road  , .Dot   , .Road  , .Road  , .Road  , .Road  ],
            [.Police, .Road  , .Police, .Road  , .Road  , .Road  , .Police, .Police, .Road  ],
            [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Road  ],
            [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Police],
            [.Police, .Road  , .Road  , .Road  , .Road  , .Road  , .Police, .Police, .Police],
            [.Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police],
        ]
        game.dotPosition = NodePosition(line: 3, column: 4)
        if let nextPosition = game.searchNext() {
            XCTAssertEqual(nextPosition, NodePosition(line: 2, column: 5))
        } else {
            XCTFail("searchNext not return the nextPosition")
        }
    }
    
    func testSearchNextShouldReturnNil() {
        game.gameData = [
            [.Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police],
            [.Police, .Road  , .Road  , .Road  , .Police, .Police, .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Road  , .Police, .Road  , .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Road  , .Dot   , .Road  , .Road  , .Road  , .Police],
            [.Police, .Road  , .Police, .Road  , .Road  , .Road  , .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Road  ],
            [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Police],
            [.Police, .Road  , .Road  , .Road  , .Road  , .Road  , .Police, .Police, .Police],
            [.Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police],
        ]
        game.dotPosition = NodePosition(line: 3, column: 4)
        let nextPosition = game.searchNext()
        XCTAssertEqual(nextPosition, nil)
    }
    
    func testGetCircleSortedPolices() {
        game.gameData = [
            [.Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police],
                [.Police, .Road  , .Road  , .Road  , .Police, .Police, .Police, .Police, .Police],
            [.Police, .Road  , .Police, .Road  , .Police, .Road  , .Police, .Police, .Police],
                [.Police, .Road  , .Police, .Road  , .Dot   , .Road  , .Road  , .Road  , .Police],
            [.Police, .Road  , .Police, .Road  , .Road  , .Road  , .Police, .Police, .Police],
                [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Road  ],
            [.Police, .Road  , .Police, .Police, .Police, .Road  , .Police, .Police, .Police],
                [.Police, .Road  , .Road  , .Road  , .Road  , .Road  , .Police, .Police, .Police],
            [.Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police, .Police],
        ]
        game.dotPosition = NodePosition(line: 3, column: 4)
        game.reachablePolices = [
            NodePosition(line: 5, column: 2),
            NodePosition(line: 5, column: 3),
            NodePosition(line: 5, column: 4),
            NodePosition(line: 0, column: 1),
            NodePosition(line: 0, column: 2),
            NodePosition(line: 1, column: 0),
            NodePosition(line: 7, column: 0),
            NodePosition(line: 2, column: 0),
            NodePosition(line: 3, column: 0),
            NodePosition(line: 4, column: 0),
            NodePosition(line: 0, column: 3),
            NodePosition(line: 0, column: 4),
            NodePosition(line: 2, column: 2),
            NodePosition(line: 2, column: 4),
            NodePosition(line: 1, column: 4),
            NodePosition(line: 1, column: 5),
            NodePosition(line: 2, column: 6),
            NodePosition(line: 2, column: 7),
            NodePosition(line: 2, column: 8),
            NodePosition(line: 3, column: 2),
            NodePosition(line: 3, column: 8),
            NodePosition(line: 4, column: 2),
            NodePosition(line: 4, column: 6),
            NodePosition(line: 4, column: 7),
            NodePosition(line: 4, column: 8),
            NodePosition(line: 5, column: 0),
            NodePosition(line: 5, column: 6),
            NodePosition(line: 6, column: 0),
            NodePosition(line: 6, column: 2),
            NodePosition(line: 6, column: 3),
            NodePosition(line: 6, column: 4),
            NodePosition(line: 6, column: 6),
            NodePosition(line: 7, column: 6),
            NodePosition(line: 8, column: 1),
            NodePosition(line: 8, column: 2),
            NodePosition(line: 8, column: 3),
            NodePosition(line: 8, column: 4),
            NodePosition(line: 8, column: 5),
            NodePosition(line: 8, column: 6),
        ]
        let result = [
            NodePosition(line: 0, column: 1),
            NodePosition(line: 0, column: 2),
            NodePosition(line: 0, column: 3),
            NodePosition(line: 0, column: 4),
            NodePosition(line: 1, column: 4),
            NodePosition(line: 1, column: 5),
            NodePosition(line: 2, column: 6),
            NodePosition(line: 2, column: 7),
            NodePosition(line: 2, column: 8),
            NodePosition(line: 3, column: 8),
            NodePosition(line: 4, column: 8),
            NodePosition(line: 4, column: 7),
            NodePosition(line: 4, column: 6),
            NodePosition(line: 5, column: 6),
            NodePosition(line: 6, column: 6),
            NodePosition(line: 7, column: 6),
            NodePosition(line: 8, column: 6),
            NodePosition(line: 8, column: 5),
            NodePosition(line: 8, column: 4),
            NodePosition(line: 8, column: 3),
            NodePosition(line: 8, column: 2),
            NodePosition(line: 8, column: 1),
            NodePosition(line: 7, column: 0),
            NodePosition(line: 6, column: 0),
            NodePosition(line: 5, column: 0),
            NodePosition(line: 4, column: 0),
            NodePosition(line: 3, column: 0),
            NodePosition(line: 2, column: 0),
            NodePosition(line: 1, column: 0),
        ]
        if let circlePositions = game.getCircleSortedPolices() {
            if let firstPosition = result.indexOf(circlePositions[0])?.value {
                let firstPosition = Int(firstPosition)
                for (i, position) in result[firstPosition..<result.count].enumerate() {
                    XCTAssertEqual(position, circlePositions[i], "the \(i + firstPosition)th not right")
                }
                for (i, position) in result[0..<firstPosition].enumerate() {
                    XCTAssertEqual(position, circlePositions[result.count - firstPosition + i], "the \(result.count - firstPosition + i)th not right")
                }
            } else {
                XCTFail("the first node not in the result")
            }
        } else {
            XCTFail("didn't get circle")
        }
    }
}
