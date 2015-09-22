//
//  Game.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 9/20/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import Foundation


protocol Game {
    var gameDelegate: GameDelegate? { get set }
    func play()
}

protocol GameDelegate {
    func gameDidStart(game: Game)
    
    func gameDidEnd(game: Game, withResult: GameResult?)
}

enum WinOrLose {
    case Win
    case Lose
    
    var title: String {
        switch self {
        case .Win:
            return "Win"
        case .Lose:
            return "Lose"
        }
    }
}

protocol GameResult {
    var winOrLose: WinOrLose { get set}
    
    var details: String { get }
}