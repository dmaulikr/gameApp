//
//  GameViewController.swift
//  gameApp
//
//  Created by Liza Girsova on 9/23/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

//import Cocoa
import SceneKit
import SpriteKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    var sceneView: SCNView!
    var gameSim: GameSimulation!
    var hud: HUD!
    
    override func awakeFromNib(){
        // create a new scene
        sceneView = SCNView(frame: self.view.frame)
        gameSim = GameSimulation()
        sceneView.scene = gameSim
        sceneView.playing = true
        sceneView.delegate = gameSim
        sceneView.showsStatistics = true
        
        // Needs to be initialized in main queue
        dispatch_async(dispatch_get_main_queue(), {
            // Add SKScene to function like a HUD
            self.hud = HUD(size: self.sceneView.bounds.size)
            self.sceneView.overlaySKScene = self.hud
            self.view.addSubview(self.sceneView)
        })
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}