//
//  HomeViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var titleLabel: UILabel!
    lazy var fbButton: UIButton = UIButton()
    lazy var randomView: UIView = UIView()
    lazy var easyView: UIView = UIView()
    lazy var hardView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        
        view.addSubviews([randomView, easyView, hardView])
        createModeView(.Random, containerView: randomView)
        createModeView(.Easy, containerView: easyView)
        createModeView(.Hard, containerView: hardView)
        randomView.backgroundColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1)
        easyView.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1)
        hardView.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1)
        
        randomView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.28)
        }
        easyView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(randomView.snp_bottom)
            make.height.equalTo(view).multipliedBy(0.22)
        }
        hardView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(easyView.snp_bottom)
            make.height.equalTo(view).multipliedBy(0.22)
            make.bottom.equalTo(view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tapAtLevel(gestureRecognizer: UITapGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            let level = GameLevel(hashValue: tag)
            let levelObject = Wrapper<GameLevel>(theValue: level)
            NSNotificationCenter.defaultCenter().postNotificationName("newGameWithLevel", object: nil, userInfo: ["level": levelObject])
        }
    }
    
    func createModeView(mode: GameType, containerView: UIView) {
        let titleLabel = UILabel()
        titleLabel.text = mode.title
        containerView.addSubview(titleLabel)
        
        let levelContainerStackView = UIStackView()
        levelContainerStackView.alignment = UIStackViewAlignment.Center
        levelContainerStackView.axis = UILayoutConstraintAxis.Horizontal
        levelContainerStackView.distribution = UIStackViewDistribution.EqualSpacing
        containerView.addSubview(levelContainerStackView)
        
        
        for level in mode.allLevels {
            let levelView = LevelView()
            levelView.level = level
            levelView.minSteps = -1
            levelView.tag = level.hashValue
            let tapGesture = UITapGestureRecognizer(target: self, action: "tapAtLevel:")
            levelView.addGestureRecognizer(tapGesture)
            levelContainerStackView.addArrangedSubview(levelView)
            levelView.snp_makeConstraints(closure: { (make) -> Void in
                make.width.lessThanOrEqualTo(levelContainerStackView.snp_width).multipliedBy(0.2).offset(13)
                make.bottomMargin.topMargin.equalTo(levelContainerStackView).priority(700)
                make.width.equalTo(levelView.snp_height).priority(750)
            })
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.topMargin.centerX.equalTo(containerView)
            make.height.equalTo(32)
        }
        levelContainerStackView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(12)
            make.leadingMargin.trailingMargin.equalTo(containerView)
            make.bottomMargin.equalTo(containerView).offset(-10)
        }
    }
}
