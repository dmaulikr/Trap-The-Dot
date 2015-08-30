//
//  ViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/21/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController {
    
    lazy var gameViewController: GameBoardViewController = GameBoardViewController()
    lazy var homeViewController: HomeViewController = HomeViewController()
    lazy var resultViewController: ResultViewController = ResultViewController()
    lazy var bannerView = ADBannerView(adType: ADAdType.Banner)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(bannerView)
        bannerView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.bottom.equalTo(self.view)
            make.height.equalTo(bannerView.frame.height)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replay:", name: "replay", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onceMore:", name: "onceMore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nextLevel:", name: "nextLevel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoHome:", name: "gotoHome", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showResult:", name: "showResult", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newGameWithLevel:", name: "newGameWithLevel", object: nil)
        
        navigate(nil, to: gameViewController)
    }
    
    func handleButtonClick(sender: UIButton) {
        gameViewController.view.removeFromSuperview()
        gameViewController.removeFromParentViewController()
        gameViewController = GameBoardViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func navigate(from: UIViewController?, to: UIViewController) {
        from?.view.removeFromSuperview()
        from?.removeFromParentViewController()
        
        addChildViewController(to)
        view.addSubview(to.view)
        to.view.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.bottom.equalTo(bannerView.snp_top)
        }
    }
    
    func replay(notification: NSNotification) {
    }
    
    func onceMore(notification: NSNotification) {
        navigate(resultViewController, to: gameViewController)
        gameViewController.initGame()
    }
    
    func nextLevel(notification: NSNotification) {
        navigate(resultViewController, to: gameViewController)
        if let currentLevel = GameLevel.currentLevel {
            GameLevel.currentLevel = currentLevel.nextLevel
        }
        gameViewController.initGame()
    }
    
    func gotoHome(notification: NSNotification) {
        navigate(resultViewController, to: homeViewController)
    }
    
    func newGameWithLevel(notification: NSNotification) {
        if let levelObject = notification.userInfo?["level"] as? Wrapper<GameLevel> {
            GameLevel.currentLevel = levelObject.wrappedValue
            navigate(homeViewController, to: gameViewController)
            gameViewController.initGame()
        }
    }
    
    func showResult(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let result = userInfo["result"] as! Wrapper<Result>
        navigate(gameViewController, to: resultViewController)
        resultViewController.showResult(GameLevel.currentLevel!, result: result.wrappedValue, screenShot: userInfo["snapshot"] as? UIImage)
    }
}

