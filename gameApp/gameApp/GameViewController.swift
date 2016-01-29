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
    
    @IBOutlet var sceneView1: SCNView!
    @IBOutlet var sceneView2: SCNView!
    
    var gameSim: GameSimulation!
    var hud: HUD!
    var hud2: HUD!
    
    override func awakeFromNib(){
        gameSim = GameSimulation()
        
        // Set up player 1 scene
        sceneView1.scene = gameSim
        sceneView1.playing = true
        sceneView1.delegate = gameSim
        //sceneView1.showsStatistics = true
        sceneView1.pointOfView = (gameSim.gameLevel.playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).ownCameraNode()
        
        // Set up player 2 scene
        sceneView2.scene = gameSim
        sceneView2.playing = true
        sceneView2.delegate = gameSim
        //sceneView2.showsStatistics = true
        sceneView2.pointOfView = (gameSim.gameLevel.playerDict.objectForKey(Player.ID.ID2.hashValue) as! Player).ownCameraNode()
        
        // Needs to be initialized in main queue
        
        // Add SKScene to function like a HUD
        self.hud = HUD(size: self.sceneView1.bounds.size)
        self.hud2 = HUD(size: self.sceneView2.bounds.size)
        
        self.sceneView1.overlaySKScene = self.hud
        self.sceneView1.prepareObject(self.sceneView1.scene!, shouldAbortBlock:nil) // caches
        
        self.sceneView2.overlaySKScene = self.hud2
        self.sceneView2.prepareObject(self.sceneView2.scene!, shouldAbortBlock:nil) // caches
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHUD:", name: Constants.Notifications.updateHUD, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hudSetDeadView:", name: Constants.Notifications.setHudDeadView, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func hudSetDeadView(notification: NSNotification) {
        let dict:Dictionary<String,AnyObject> = notification.userInfo as! Dictionary<String,AnyObject>
        let playerIDHash = dict["playerID"]
        if playerIDHash!.isEqual(Player.ID.ID1.hashValue) {
            self.hud.setDeadView()
        } else {
            self.hud2.setDeadView()
        }
    }
    
    func updateHUD(notification: NSNotification) {
        let dict:Dictionary<String,AnyObject> = notification.userInfo as! Dictionary<String,AnyObject>
        let playerIDHash = dict["playerID"]
        dispatch_async(dispatch_get_main_queue(), {
            if playerIDHash!.isEqual(Player.ID.ID1.hashValue) {
                // update hud
                if let health = dict["health"] {
                    self.hud.updateHealthLabel("Health: \(health)")
                } else {
                    let ammoLoaded = dict["ammoLoaded"]
                    let ammoCarried = dict["ammoCarried"]
                    self.hud.updateAmmoLabel("\(ammoLoaded!) | \(ammoCarried!)")
                }
            } else {
                // update hud2
                if let health = dict["health"] {
                    self.hud2.updateHealthLabel("Health: \(health)")
                } else {
                    let ammoLoaded = dict["ammoLoaded"]
                    let ammoCarried = dict["ammoCarried"]
                    self.hud2.updateAmmoLabel("\(ammoLoaded!) | \(ammoCarried!)")
                }
            }
        })
    }
    
}