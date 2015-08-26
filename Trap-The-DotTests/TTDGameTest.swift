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
        
        XCTAssertEqual(game.dotIndex, NodeIndex(line: 4, column: 4))
        
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
    
    func testCheckIndexValid() {
        XCTAssertFalse(game.checkIndexValid(NodeIndex(line: 10, column: 8)), "(line: 9, column: 8) should be invaild")
        XCTAssertFalse(game.checkIndexValid(NodeIndex(line: 0, column: -1)), "(line: 0, column: -1) should be invaild")
        XCTAssertTrue(game.checkIndexValid(NodeIndex(line: 0, column: 0)), "(line: 0, column: 0) should be vaild")
        XCTAssertTrue(game.checkIndexValid(NodeIndex(line: 8, column: 8)), "(line: 8, column: 8) should be vaild")
    }
    
    func testSearchNextShouldReturnTheRightNextIndex() {
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
        game.dotIndex = NodeIndex(line: 3, column: 4)
        if let nextIndex = game.searchNext() {
            XCTAssertEqual(nextIndex, NodeIndex(line: 2, column: 5))
        } else {
            XCTFail("searchNext not return the nextIndex")
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
        game.dotIndex = NodeIndex(line: 3, column: 4)
        let nextIndex = game.searchNext()
        XCTAssertEqual(nextIndex, nil)
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
        game.dotIndex = NodeIndex(line: 3, column: 4)
        game.reachablePolices = [
            NodeIndex(line: 5, column: 2),
            NodeIndex(line: 5, column: 3),
            NodeIndex(line: 5, column: 4),
            NodeIndex(line: 0, column: 1),
            NodeIndex(line: 0, column: 2),
            NodeIndex(line: 1, column: 0),
            NodeIndex(line: 7, column: 0),
            NodeIndex(line: 2, column: 0),
            NodeIndex(line: 3, column: 0),
            NodeIndex(line: 4, column: 0),
            NodeIndex(line: 0, column: 3),
            NodeIndex(line: 0, column: 4),
            NodeIndex(line: 2, column: 2),
            NodeIndex(line: 2, column: 4),
            NodeIndex(line: 1, column: 4),
            NodeIndex(line: 1, column: 5),
            NodeIndex(line: 2, column: 6),
            NodeIndex(line: 2, column: 7),
            NodeIndex(line: 2, column: 8),
            NodeIndex(line: 3, column: 2),
            NodeIndex(line: 3, column: 8),
            NodeIndex(line: 4, column: 2),
            NodeIndex(line: 4, column: 6),
            NodeIndex(line: 4, column: 7),
            NodeIndex(line: 4, column: 8),
            NodeIndex(line: 5, column: 0),
            NodeIndex(line: 5, column: 6),
            NodeIndex(line: 6, column: 0),
            NodeIndex(line: 6, column: 2),
            NodeIndex(line: 6, column: 3),
            NodeIndex(line: 6, column: 4),
            NodeIndex(line: 6, column: 6),
            NodeIndex(line: 7, column: 6),
            NodeIndex(line: 8, column: 1),
            NodeIndex(line: 8, column: 2),
            NodeIndex(line: 8, column: 3),
            NodeIndex(line: 8, column: 4),
            NodeIndex(line: 8, column: 5),
            NodeIndex(line: 8, column: 6),
        ]
        let result = [
            NodeIndex(line: 0, column: 1),
            NodeIndex(line: 0, column: 2),
            NodeIndex(line: 0, column: 3),
            NodeIndex(line: 0, column: 4),
            NodeIndex(line: 1, column: 4),
            NodeIndex(line: 1, column: 5),
            NodeIndex(line: 2, column: 6),
            NodeIndex(line: 2, column: 7),
            NodeIndex(line: 2, column: 8),
            NodeIndex(line: 3, column: 8),
            NodeIndex(line: 4, column: 8),
            NodeIndex(line: 4, column: 7),
            NodeIndex(line: 4, column: 6),
            NodeIndex(line: 5, column: 6),
            NodeIndex(line: 6, column: 6),
            NodeIndex(line: 7, column: 6),
            NodeIndex(line: 8, column: 6),
            NodeIndex(line: 8, column: 5),
            NodeIndex(line: 8, column: 4),
            NodeIndex(line: 8, column: 3),
            NodeIndex(line: 8, column: 2),
            NodeIndex(line: 8, column: 1),
            NodeIndex(line: 7, column: 0),
            NodeIndex(line: 6, column: 0),
            NodeIndex(line: 5, column: 0),
            NodeIndex(line: 4, column: 0),
            NodeIndex(line: 3, column: 0),
            NodeIndex(line: 2, column: 0),
            NodeIndex(line: 1, column: 0),
        ]
        if let circleIndexes = game.getCircleSortedPolices() {
            if let firstIndex = result.indexOf(circleIndexes[0])?.value {
                let firstIndex = Int(firstIndex)
                for (i, index) in result[firstIndex..<result.count].enumerate() {
                    XCTAssertEqual(index, circleIndexes[i], "the \(i + firstIndex)th not right")
                }
                for (i, index) in result[0..<firstIndex].enumerate() {
                    XCTAssertEqual(index, circleIndexes[result.count - firstIndex + i], "the \(result.count - firstIndex + i)th not right")
                }
            } else {
                XCTFail("the first node not in the result")
            }
        } else {
            XCTFail("didn't get circle")
        }
    }
}
