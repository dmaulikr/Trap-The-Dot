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
    
    func createModeView(mode: GameMode, containerView: UIView) {
        let titleLabel = UILabel()
        titleLabel.text = mode.title
        containerView.addSubview(titleLabel)
        let levelContainerView: UIView
        let createLevelView = { (level: GameLevel) -> LevelView in
            let levelView = LevelView()
            levelView.backgroundColor = Theme.currentTheme.secondaryColor
            levelView.level = level
            levelView.minSteps = -1
            levelView.tag = level.hashValue
            let tapGesture = UITapGestureRecognizer(target: self, action: "tapAtLevel:")
            levelView.addGestureRecognizer(tapGesture)
            return levelView
        }
        
        if #available(iOS 9, *) {
            let allLevels = mode.allLevels
            if allLevels.count > 1 {
                let levelContainerStackView = UIStackView()
                levelContainerStackView.alignment = UIStackViewAlignment.Center
                levelContainerStackView.axis = UILayoutConstraintAxis.Horizontal
                levelContainerStackView.distribution = UIStackViewDistribution.EqualSpacing
                containerView.addSubview(levelContainerStackView)
                
                for level in allLevels {
                    let levelView = createLevelView(level)
                    levelContainerStackView.addArrangedSubview(levelView)
                    levelView.snp_makeConstraints(closure: { (make) -> Void in
                        make.width.lessThanOrEqualTo(levelContainerStackView.snp_width).multipliedBy(0.2).offset(13)
                        make.bottomMargin.topMargin.equalTo(levelContainerStackView).priority(700)
                        make.width.equalTo(levelView.snp_height).priority(750)
                    })
                }
                levelContainerView = levelContainerStackView
            } else {
                levelContainerView = UIView()
                containerView.addSubview(levelContainerView)
                
                let level = allLevels[0]
                let levelView = createLevelView(level)
                levelContainerView.addSubview(levelView)
                levelView.snp_makeConstraints(closure: { (make) -> Void in
                    make.width.lessThanOrEqualTo(levelContainerView.snp_width).multipliedBy(0.2).offset(13)
                    make.bottomMargin.topMargin.equalTo(levelContainerView).priority(700)
                    make.width.equalTo(levelView.snp_height).priority(750)
                    make.centerX.equalTo(levelContainerView)
                })
            }
            
            levelContainerView.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(titleLabel.snp_bottom).offset(12)
                make.leadingMargin.trailingMargin.equalTo(containerView)
                make.bottomMargin.equalTo(containerView).offset(-10)
            }
        } else {
            
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.topMargin.centerX.equalTo(containerView)
            make.height.equalTo(32)
        }
    }
}
