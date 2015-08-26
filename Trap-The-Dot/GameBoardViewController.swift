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
    let game = TTDGame(lines: 9, columns: 9)
    
    private var reachablePolices = [NodeIndex]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        soundButton.backgroundColor = UIColor.blackColor()
        colorButton.backgroundColor = UIColor.blackColor()
        stepsLabel.text = "0 step"
        
        game.initData(20)
        gameBoardView = GameBoardView(data: game.gameData)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                gameBoardView.moveDotFrom(game.dotIndex, toIndex: nextIndex)
                game.dotIndex = nextIndex
                return
            } else {
                showResult(.Fail)
                return
            }
        }
        if let circlePolices = game.getCircleSortedPolices() {
            gameBoardView.linkCirclePolices(circlePolices)
            showResult(.Win)
        }
    }
    
    func showResult(result: Result) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
        self.showViewController(alert, sender: nil)
    }
}
