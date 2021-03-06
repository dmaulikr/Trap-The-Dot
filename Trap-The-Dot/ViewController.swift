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
    
    lazy var myNavigationController: NavigationController = NavigationController()
    lazy var bannerView = ADBannerView(adType: ADAdType.Banner)
    
    var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = Theme.currentTheme.primaryBackgroundColor
        
        view.addSubview(bannerView)
        bannerView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.bottom.equalTo(self.view)
            make.height.equalTo(bannerView.frame.height)
        }
        
        addChildViewController(myNavigationController)
        view.addSubview(myNavigationController.view)
        myNavigationController.view.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.bottom.equalTo(bannerView.snp_top)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func navigateTo(viewController: UIViewController) {
        currentViewController?.view.hidden = true
        
        if viewController.parentViewController == nil {
            addChildViewController(viewController)
            view.addSubview(viewController.view)
            viewController.view.snp_makeConstraints { (make) -> Void in
                make.leading.trailing.equalTo(self.view)
                make.top.equalTo(self.snp_topLayoutGuideBottom)
                make.bottom.equalTo(bannerView.snp_top)
            }
        }
        currentViewController = viewController
        currentViewController?.view.hidden = false
    }
//    
//    func onceMore(notification: NSNotification) {
//        navigateTo(gameViewController)
//        gameViewController.initGame()
//    }
//    
//    func nextLevel(notification: NSNotification) {
//        navigateTo(gameViewController)
//        if let currentLevel = GameLevel.currentLevel {
//            GameLevel.currentLevel = currentLevel.nextLevel
//        }
//        gameViewController.initGame()
//    }
//    
//    func gotoHome(notification: NSNotification) {
//        navigateTo(homeViewController)
//    }
//    
//    func newGameWithLevel(notification: NSNotification) {
//        if let levelObject = notification.userInfo?["level"] as? Wrapper<GameLevel> {
//            GameLevel.currentLevel = levelObject.wrappedValue
//            navigateTo(gameViewController)
//            gameViewController.initGame()
//        }
//    }
//    
//    func showResult(notification: NSNotification) {
//        guard let userInfo = notification.userInfo else {
//            return
//        }
//        let result = userInfo["result"] as! Wrapper<Result>
//        navigateTo(resultViewController)
//        resultViewController.showResult(GameLevel.currentLevel!, result: result.wrappedValue, screenShot: userInfo["snapshot"] as? UIImage, totalSteps: userInfo["totalSteps"] as! Int)
//    }
}

