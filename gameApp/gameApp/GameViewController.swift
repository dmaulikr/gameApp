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
    
    @IBOutlet weak var sceneView1: SCNView!
    @IBOutlet weak var sceneView2: SCNView!
    var gameSim: GameSimulation!
    var hud: HUD!
    var hud2: HUD!
    
    override func awakeFromNib(){
        // enterFullScreenMode made everything blank
        // self.view.enterFullScreenMode(NSScreen.mainScreen()!, withOptions:nil)
        
        gameSim = GameSimulation()
        
        // Set up player 1 scene
        sceneView1.scene = gameSim
        sceneView1.playing = true
        sceneView1.delegate = gameSim
        sceneView1.showsStatistics = true
        sceneView1.pointOfView = (gameSim.gameLevel.playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).ownCameraNode()
        
        // Set up player 2 scene
        sceneView2.scene = gameSim
        sceneView2.playing = true
        sceneView2.delegate = gameSim
        sceneView2.showsStatistics = true
        sceneView2.pointOfView = (gameSim.gameLevel.playerDict.objectForKey(Player.ID.ID2.hashValue) as! Player).ownCameraNode()
        
        // Needs to be initialized in main queue
        dispatch_async(dispatch_get_main_queue(), {
            // Add SKScene to function like a HUD
            self.hud = HUD(size: self.sceneView1.bounds.size)
            self.sceneView1.overlaySKScene = self.hud
            self.sceneView1.prepareObject(self.sceneView1.scene!, shouldAbortBlock:nil) // caches
            //self.view.addSubview(self.sceneView1)
            
            self.hud2 = HUD(size: self.sceneView2.bounds.size)
            self.sceneView2.overlaySKScene = self.hud2
            self.sceneView2.prepareObject(self.sceneView2.scene!, shouldAbortBlock:nil) // caches
        })
    
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}