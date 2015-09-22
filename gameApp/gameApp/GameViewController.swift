//
//  GameViewController.swift
//  gameApp
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright (c) 2015 Girsova. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    // First create a ServiceManager instance
    var serviceManager = ServiceManager()
    let addAccessibilityCodeNK = "elg-addAccessibilityCode"
    let scene = SCNScene()
    var codeText: SCNText?
    var cameraNode: SCNNode?
    
    override func awakeFromNib(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addAccessibilityCode:", name: addAccessibilityCodeNK, object: nil)
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode!.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode!)
        
        // place the camera
        cameraNode!.position = SCNVector3(x: 0, y: 0, z: 50)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)

        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.whiteColor()
    }
    
    func addAccessibilityCode(notification: NSNotification) {
        print("In addAccessibilityCode")
        
        // Get code information
        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
        let accessibilityCode = userInfo["accessibilityCode"]
        
        // Create SCNText with necessary code information
        codeText = SCNText(string: String(accessibilityCode!), extrusionDepth: 2.0)
        codeText!.firstMaterial?.diffuse.contents = NSColor.blackColor()
        codeText!.font = NSFont.systemFontOfSize(8.0)
        let codeNode = SCNNode(geometry: codeText)
        codeNode.position = SCNVector3Make(0, 0, 0)
        
        let cameraConstraint = SCNLookAtConstraint(target: codeNode)
        cameraNode?.constraints = [cameraConstraint]
        
        scene.rootNode.addChildNode(codeNode)
        
    }

}
