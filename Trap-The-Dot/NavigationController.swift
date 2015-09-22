//
//  NavigationController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 9/20/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var game: TTDGame {
        return TTDGame.sharedGame
    }
    
    lazy var gameViewController: GameBoardViewController = GameBoardViewController()
    lazy var homeViewController: HomeViewController = HomeViewController()
    lazy var resultViewController: ResultViewController = ResultViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden = true

        game.gameDelegate = self
        game.playDelegate = gameViewController
        
        setViewControllers([gameViewController], animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoHome:", name: "gotoHome", object: nil)
        
        game.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoHome(sender: AnyObject) {
        setViewControllers([homeViewController], animated: true)
    }
}

extension NavigationController: GameDelegate {
    func gameDidStart(game: Game) {
        setViewControllers([gameViewController], animated: true)
    }
    
    func gameDidEnd(game: Game, withResult result: GameResult?) {
        resultViewController.result = result as? TTDGameResult
        setViewControllers([resultViewController], animated: true)
        gameViewController.resetGameBoard()
    }
}
