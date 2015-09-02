//
//  GameBoardViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/21/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit
import SnapKit

class GameBoardViewController: UIViewController {

    var titleLabel: UILabel!
    lazy var soundButton: UIButton = UIButton()
    lazy var colorButton: UIButton = UIButton()
    lazy var stepsLabel: UILabel = UILabel()
    var gameBoardView: GameBoardView!
    
    let gameLines = 9
    let gameColumns = 9
    var game: TTDGame!
    
    private var reachablePolices = [NodePosition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        soundButton.backgroundColor = UIColor.blackColor()
        soundButton.setBackgroundImage(UIImage(named: "images/soundOff.png"), forState: .Normal)
        colorButton.setBackgroundImage(UIImage(named: "images/colorLess.png"), forState: .Normal)
        stepsLabel.text = "0 step"
        
        game = TTDGame(lines: gameLines, columns: gameColumns)
        gameBoardView = GameBoardView(lines: gameLines, columns: gameColumns)
        
        view.addSubviews([soundButton, colorButton, stepsLabel, gameBoardView])
        
        soundButton.snp_makeConstraints { (make) -> Void in
            make.leadingMargin.equalTo(self.view)
            make.top.equalTo(self.view).offset(10)
            make.width.height.equalTo(44)
        }
        colorButton.snp_makeConstraints { (make) -> Void in
            make.trailingMargin.equalTo(self.view)
            make.top.equalTo(self.view).offset(10)
            make.width.height.equalTo(44)
        }
        stepsLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(gameBoardView.snp_top)
        }
        gameBoardView.snp_makeConstraints { (make) -> Void in
            make.leadingMargin.trailingMargin.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-30)
            make.height.equalTo(gameBoardView.snp_width).multipliedBy(nodeHeightWidthRatio)
        }
        
        gameBoardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        gameBoardView.backgroundColor = view.backgroundColor
        
        initGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initGame() {
        guard let currentLevel = GameLevel.currentLevel else {
            NSNotificationCenter.defaultCenter().postNotificationName("gotoHome", object: nil)
            return
        }
        
        game.initData(currentLevel.policeNumber)
        gameBoardView.initGameViewWithData(game.gameData)
        
        if game.searchNext() == nil {
            if let circlePolices = game.getCircleSortedPolices() {
                gameBoardView.userInteractionEnabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.gameBoardView.linkCirclePolices(circlePolices, complete: { () -> () in
                        self.showResult(.Win)
                        self.gameBoardView.userInteractionEnabled = true
                        return
                    })
                })
            }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.locationInView(gameBoardView)
        
        if let index = gameBoardView.indexOfPosition(position) {
            if game.checkPositionValid(index) {
                if game.gameData[index.line][index.column] == NodeType.Road {
                    accumulateStep()
                    game.gameData[index.line][index.column] = .Police
                    trapAt(index)
                }
            }
        }
    }
    
    func accumulateStep() {
        game.currentSteps++
        stepsLabel.text = "\(game.currentSteps) Step"
    }
    
    func trapAt(position: NodePosition) {
        gameBoardView.changeIndexToType(position, type: .Police)
        if let nextPosition = game.searchNext() {
            if game.checkPositionValid(nextPosition) {
                game.gameData[game.dotPosition.line][game.dotPosition.column] = .Road
                gameBoardView.userInteractionEnabled = false
                gameBoardView.moveDotFrom(game.dotPosition, toIndex: nextPosition, complete: { () -> () in
                    self.game.gameData[nextPosition.line][nextPosition.column] = .Dot
                    self.game.dotPosition = nextPosition
                    self.gameBoardView.userInteractionEnabled = true
                })
                
                return
            } else {
                self.gameBoardView.userInteractionEnabled = false
                gameBoardView.dotEscapeTo(nextPosition, from: game.dotPosition) {
                    self.gameBoardView.userInteractionEnabled = true
                    self.showResult(.Fail)
                }
                return
            }
        }
        if let circlePolices = game.getCircleSortedPolices() {
            self.gameBoardView.userInteractionEnabled = false
            gameBoardView.linkCirclePolices(circlePolices, complete: { () -> () in
                self.showResult(.Win)
                self.gameBoardView.userInteractionEnabled = true
                return
            })
        }
    }
    
    func showResult(result: Result) {
        let snapshot = view.takeSnapshot()
        NSNotificationCenter.defaultCenter().postNotificationName("showResult", object: nil, userInfo: ["result": Wrapper(theValue: result), "snapshot": snapshot, "totalSteps": game.currentSteps])
    }
}
