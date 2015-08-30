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
    
    private var reachablePolices = [NodeIndex]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        soundButton.backgroundColor = UIColor.blackColor()
        colorButton.backgroundColor = UIColor.blackColor()
        stepsLabel.text = "0 step"
        
        game = TTDGame(lines: gameLines, columns: gameColumns)
        gameBoardView = GameBoardView(lines: gameLines, columns: gameColumns)
        
        self.view.addSubview(soundButton)
        self.view.addSubview(colorButton)
        self.view.addSubview(stepsLabel)
        self.view.addSubview(gameBoardView)
        
        soundButton.snp_makeConstraints { (make) -> Void in
            make.leading.top.equalTo(self.view)
            make.width.height.equalTo(44)
        }
        colorButton.snp_makeConstraints { (make) -> Void in
            make.trailing.top.equalTo(self.view)
            make.width.height.equalTo(44)
        }
        stepsLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(gameBoardView.snp_top)
        }
        gameBoardView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-30)
            make.height.equalTo(gameBoardView.snp_width).multipliedBy(nodeHeightWidthRatio)
        }
        
        gameBoardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        
        view.backgroundColor = UIColor.lightGrayColor()
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.gameBoardView.linkCirclePolices(circlePolices)
                    self.showResult(.Win)
                })
            }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.locationInView(gameBoardView)
        
        if let index = gameBoardView.indexOfPosition(position) {
            if game.checkIndexValid(index) {
                if game.gameData[index.line][index.column] == NodeType.Road {
                    game.gameData[index.line][index.column] = .Police
                    trapAt(index)
                }
            }
        }
    }
    
    func trapAt(index: NodeIndex) {
        gameBoardView.changeIndexToType(index, type: .Police)
        if let nextIndex = game.searchNext() {
            if game.checkIndexValid(nextIndex) {
                game.gameData[game.dotIndex.line][game.dotIndex.column] = .Road
                game.gameData[nextIndex.line][nextIndex.column] = .Dot
                gameBoardView.moveDotFrom(game.dotIndex, toIndex: nextIndex, game: game)
                game.dotIndex = nextIndex
                return
            } else {
                gameBoardView.dotEscapeTo(nextIndex, from: game.dotIndex) {
                    self.showResult(.Fail)
                }
                return
            }
        }
        if let circlePolices = game.getCircleSortedPolices() {
            gameBoardView.linkCirclePolices(circlePolices)
            showResult(.Win)
        }
    }
    
    func showResult(result: Result) {
        let snapshot = view.takeSnapshot()
        NSNotificationCenter.defaultCenter().postNotificationName("showResult", object: nil, userInfo: ["result": Wrapper(theValue: result), "snapshot": snapshot])
    }
}
