//
//  GameBoardViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/21/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit
import SnapKit
import AudioToolbox
import AVFoundation

var voiceEnabled: Bool = {
    return NSUserDefaults.standardUserDefaults().valueForKey("voiceEnabled") as? Bool ?? true
}()

func toggleVoiceEnable() {
    voiceEnabled = !voiceEnabled
    NSUserDefaults.standardUserDefaults().setBool(voiceEnabled, forKey: "voiceEnabled")
    NSUserDefaults.standardUserDefaults().synchronize()
}

class GameBoardViewController: UIViewController {

    var titleLabel: UILabel!
    lazy var soundButton: UIButton = UIButton()
    lazy var colorButton: UIButton = UIButton()
    lazy var stepsLabel: UILabel = UILabel()
    var gameBoardView: GameBoardView!

    var game: TTDGame {
        return TTDGame.sharedGame
    }
    
    private var reachablePolices = [NodePosition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        soundButton.setBackgroundImage(UIImage(named: "images/soundOff.png"), forState: .Selected)
        soundButton.setBackgroundImage(UIImage(named: "images/soundOn.png"), forState: .Normal)
        colorButton.setBackgroundImage(UIImage(named: "images/colorLess.png"), forState: .Selected)
        colorButton.setBackgroundImage(UIImage(named: "images/colorful.png"), forState: .Normal)
        soundButton.selected = voiceEnabled
        colorButton.selected = (Theme.currentTheme == Theme.mainTheme)
        stepsLabel.text = "0 step"
        
        gameBoardView = GameBoardView(lines: game.lines, columns: game.columns)
        
        view.addSubviews([soundButton, stepsLabel, gameBoardView])
        
        soundButton.snp_makeConstraints { (make) -> Void in
            make.leadingMargin.equalTo(self.view)
            make.top.equalTo(self.view).offset(10)
            make.width.height.equalTo(36)
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
        
        gameBoardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GameBoardViewController.handleTap(_:))))
        
        gameBoardView.backgroundColor = view.backgroundColor
        
        soundButton.addTarget(self, action: #selector(toggleSound(_:)), forControlEvents: .TouchUpInside)
        colorButton.addTarget(self, action: #selector(toggleColor(_:)), forControlEvents: .TouchUpInside)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(replay(_:)), name: "replay", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onceMore(_:)), name: "onceMore", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(nextLevel(_:)), name: "nextLevel", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if game.state == GameState.UnInited || game.state == GameState.Ended {
            game.initData(GameLevel.currentLevel)
        }
        game.play()
    }
    
    func replay(sender: AnyObject) {
        game.replay()
    }
    
    func onceMore(sender: AnyObject) {
        game.onceMore()
    }
    
    func nextLevel(sender: AnyObject) {
        game.nextLevel()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.locationInView(gameBoardView)
        
        if let position = gameBoardView.indexOfPosition(position) {
            game.trapAt(position)
        }
    }
    
    func playSound(soundFile: String) {
        guard let soundURL = NSURL(string: (NSBundle.mainBundle().resourcePath! + "/" + soundFile)) else {
            return
        }
        if voiceEnabled {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                
                let soundID = UnsafeMutablePointer<SystemSoundID>.alloc(1)
                if AudioServicesCreateSystemSoundID(soundURL, soundID) == 0 {
                    AudioServicesPlayAlertSound(soundID.memory)
                }
            } catch let error as NSError {
                logger.error("\(error)")
            }
        }
    }
    
    func toggleSound(sender: AnyObject) {
        toggleVoiceEnable()
        soundButton.selected = !soundButton.selected
    }
    
    func toggleColor(sender: AnyObject) {
        colorButton.selected = !colorButton.selected
        Theme.currentTheme = [Theme.mainTheme, Theme.grayTheme].filter({ $0 != Theme.currentTheme }).first!
    }
    
    func resetGameBoard() {
        gameBoardView.resetGameBoard()
        stepsLabel.text = "0 step"
    }
}

extension GameBoardViewController: TTDPlayDelegate {
    func viewScreenshot(game: TTDGame) -> UIImage? {
        return view.takeSnapshot()
    }
    
    func dataDidInited(game: TTDGame) {
        gameBoardView.initGameViewWithData(game.gameData)
        
        if game.searchNext() == nil {
            game.end(.Win)
        }
    }
    
    func dataDidUpdated(game: TTDGame) {
        stepsLabel.text = "\(game.currentSteps) steps"
        playSound("sounds/dot.mp3")
        if game.state == .Ended {
            return;
        }
        
        if let previousDotPosition = game.previousDotPosition {
            gameBoardView.userInteractionEnabled = false
            gameBoardView.moveDotFrom(previousDotPosition, toIndex: game.dotPosition, complete: { () -> () in
                self.gameBoardView.userInteractionEnabled = true
            })
        } else {
            logger.error("previous position empty")
        }
        if let previousData = game.previousData {
            for (line, lineData) in previousData.enumerate() {
                for (column, type) in lineData.enumerate() {
                    if type == .Road && game.gameData[line][column] == NodeType.Police {
                        gameBoardView.changeIndexToType(NodePosition(line: line, column: column), type: .Police)
                    }
                }
            }
        }
    }
    
    func endAnimation(game: TTDGame, complete: () -> ()) {
        gameBoardView.userInteractionEnabled = false
        
        if let circlePolices = game.getCircleSortedPolices() {
            gameBoardView.linkCirclePolices(circlePolices, complete: { () -> () in
                self.gameBoardView.userInteractionEnabled = true
                complete()
            })
        } else {
            if let escapePosition = game.searchEscapePosition() {
                gameBoardView.dotEscapeTo(escapePosition, from: game.dotPosition) {
                    self.gameBoardView.userInteractionEnabled = true
                    complete()
                }
            }
        }
    }
}