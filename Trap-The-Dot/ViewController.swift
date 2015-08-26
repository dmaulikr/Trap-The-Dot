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
    lazy var bannerView: ADBannerView = ADBannerView(adType: ADAdType.Banner)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(bannerView)
        bannerView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.bottom.equalTo(self.view)
            make.height.equalTo(bannerView.frame.height)
        }
        
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
        addChildViewController(to)
        view.addSubview(to.view)
        to.view.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.bottom.equalTo(bannerView.snp_top)
        }
    }

}

