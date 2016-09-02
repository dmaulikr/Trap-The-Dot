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
        delegate = self

        game.gameDelegate = self
        game.playDelegate = gameViewController
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.gotoHome(_:)), name: "gotoHome", object: nil)
        
        setViewControllers([gameViewController], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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


extension NavigationController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}