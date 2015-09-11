//
//  Record.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 9/11/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation


let kRecordDict = "recordDict"

struct Record {
    static var recordsDict: [String: Int] = {
        return NSUserDefaults.standardUserDefaults().valueForKey(kRecordDict) as? [String: Int] ?? [:]
    }()
    
    static func addRecord(level: GameLevel, value: Int) {
        if let oldValue = recordsDict["\(level.hashValue)"] where oldValue < value {
            return
        }
        recordsDict["\(level.hashValue)"] = value
        
        NSUserDefaults.standardUserDefaults().setValue(recordsDict, forKey: kRecordDict)
    }
    
    static func getRecord(level: GameLevel) -> Int {
        return recordsDict["\(level.hashValue)"] ?? Int.max
    }
}