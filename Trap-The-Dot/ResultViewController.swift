//
//  ResultViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

enum Result {
    case Win
    case Fail
    
    var title: String {
        return self == .Win ? "✌️" : "输了"
    }
    
    var message: String {
        return self == .Win ? "赢了" : "输了"
    }
}

class ResultViewController: UIViewController {
    
    var titleLabel: UILabel!
    lazy var resultTitleLabel = UILabel()
    lazy var resultDescriptionLabel = UILabel()
    
    lazy var buttonsStackView = UIStackView()
    
    lazy var replayButton = UIButton()
    lazy var onceMoreButton = UIButton()
    lazy var nextButton = UIButton()
    lazy var shareButton = UIButton()
    lazy var commentButton = UIButton()
    lazy var homeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        
        replayButton.setTitle("Replay", forState: .Normal)
        onceMoreButton.setTitle("Once Again", forState: .Normal)
        nextButton.setTitle("Next Level", forState: .Normal)
        shareButton.setTitle("Share", forState: .Normal)
        commentButton.setTitle("Comment Me", forState: .Normal)
        homeButton.setTitle("Home", forState: .Normal)
        
        for button in [replayButton, onceMoreButton, nextButton, shareButton, commentButton, homeButton] {
            button.backgroundColor = UIColor.darkGrayColor()
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        
        buttonsStackView.axis = .Vertical
        buttonsStackView.alignment = .Center
        buttonsStackView.distribution = .Fill
        buttonsStackView.spacing = 40
        buttonsStackView.backgroundColor = UIColor.blueColor()
        
        view.addSubviews([resultTitleLabel, resultDescriptionLabel, buttonsStackView])
        
        resultTitleLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
        }
        resultDescriptionLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(resultTitleLabel.snp_bottom).offset(20)
        }
        buttonsStackView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.bottom.lessThanOrEqualTo(self.view).offset(-32)
            make.top.equalTo(resultDescriptionLabel.snp_bottom).offset(40)
        }
        
        replayButton.addTarget(self, action: "replay:", forControlEvents: .TouchUpInside)
        onceMoreButton.addTarget(self, action: "onceMore:", forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: "nextLevel:", forControlEvents: .TouchUpInside)
        shareButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
        commentButton.addTarget(self, action: "comment:", forControlEvents: .TouchUpInside)
        homeButton.addTarget(self, action: "gotoHome:", forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showResult(level: GameLevel, result: Result, screenShot: UIImage?) {
        resultTitleLabel.text = result.title
        resultDescriptionLabel.text = result.message
        
        if level.mode == .Random {
            if result == .Win {
                buttonsStackView.addArrangedSubviews([ onceMoreButton, shareButton, commentButton, homeButton ])
            } else {
                buttonsStackView.addArrangedSubviews([ onceMoreButton, commentButton, homeButton ])
            }
        } else {
            if result == .Win {
                buttonsStackView.addArrangedSubviews([ nextButton, shareButton, commentButton, homeButton ])
            } else {
                buttonsStackView.addArrangedSubviews([ onceMoreButton, commentButton, homeButton ])
            }
        }
        
        for button in [replayButton, onceMoreButton, nextButton, shareButton, commentButton, homeButton] {
            if button.superview == buttonsStackView {
                button.snp_makeConstraints(closure: { (make) -> Void in
                    make.width.equalTo(buttonsStackView).offset(-120)
                    make.height.equalTo(50)
                })
            }
        }
    }
    
    func replay(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("replay", object: nil)
    }
    
    func onceMore(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("onceMore", object: nil)
    }
    
    func nextLevel(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("nextLevel", object: nil)
    }
    
    func share(sender: AnyObject?) {
        
    }
    
    func comment(sender: AnyObject?) {
        let appid = "922876408"
        let rateURL = "itms-apps://itunes.apple.com/app/id\(appid)"
        UIApplication.sharedApplication().openURL(NSURL(string: rateURL)!)
    }
    
    func gotoHome(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("gotoHome", object: nil)
    }
}
