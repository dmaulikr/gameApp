//
//  GameViewController.swift
//  gameApp
//
//  Created by Liza Girsova on 9/23/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

//import Cocoa
import SceneKit
import QuartzCore

struct Keystroke {
    enum InteractionType {
        case Button
        case Trackpad
    }
    enum TrackpadType {
        case Movement
        case Camera
    }
    enum GestureType {
        case Tap
        case Pan
    }
    enum Button {
        case Crouch
        case Jump
        case Attack
        case Interact
    }
    
    var interactionType: InteractionType?
    var trackpadType: TrackpadType?
    var gestureType: GestureType?
    var button: Button?
    var panTranslation: CGPoint?
    var panStart: Bool?
    
    init() {
        self.interactionType = nil
    }
    
    init(interactionType: InteractionType) {
        self.interactionType = interactionType
    }
}

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    let kPlayerControlsNK = "elg-playerControls"
    var sceneView: SCNView!
    var camera: SCNNode!
    var ground: SCNNode!
    var light: SCNNode!
    var sprite: SCNNode!
    
    var oldPosition: SCNVector3!
    var newPosition: SCNVector3?
    var oldCameraPosition: SCNVector3!
    var newCameraPosition: SCNVector3?
    var oldCameraRotation: SCNVector3!
    var newCameraRotation: SCNVector3?
    
    override func awakeFromNib(){
        // create a new scene
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.scene?.physicsWorld.contactDelegate = self
        sceneView.playing = true
        sceneView.delegate = self
        //sceneView.allowsCameraControl = true
        self.view.addSubview(sceneView);
        
        // create ground
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = NSColor.lightGrayColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        
        // create character
        let spriteGeometry = SCNBox(width: 5, height: 12, length: 2, chamferRadius: 0)
        let spriteMaterial = SCNMaterial()
        spriteMaterial.diffuse.contents = NSColor.blueColor()
        spriteGeometry.materials = [spriteMaterial]
        sprite = SCNNode(geometry: spriteGeometry)
        sprite.position = SCNVector3(x: 0, y: 0, z: 0)
        
        
        // create and add a camera to the scene
        let camera = SCNCamera()
        camera.zFar = 10_000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: 0, y: 20, z: 25)
        let constraint = SCNLookAtConstraint(target: sprite)
        //constraint.gimbalLockEnabled = true
        //self.camera.constraints = [constraint]
        
        // add lighting
        let ambientLight = SCNLight()
        ambientLight.color = NSColor.lightGrayColor()
        ambientLight.type = SCNLightTypeAmbient
        self.camera.light = ambientLight
        
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.castsShadow = true
        spotLight.zFar = 30
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        light.constraints = [constraint]
        
        // add physics
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .Kinematic, shape: groundShape)
        ground.physicsBody = groundBody
        
        let spriteShape = SCNPhysicsShape(geometry: sprite.geometry!, options: nil)
        let spriteBody = SCNPhysicsBody(type: .Dynamic, shape: spriteShape)
        sprite.physicsBody = spriteBody
        
        sceneView.scene?.rootNode.addChildNode(self.camera)
        sceneView.scene?.rootNode.addChildNode(light)
        sceneView.scene?.rootNode.addChildNode(ground)
        sceneView.scene?.rootNode.addChildNode(sprite)
        
        sceneView.showsStatistics = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerControls:", name: kPlayerControlsNK, object: nil)
        
        oldCameraRotation = self.camera.eulerAngles
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func playerControls(notification: NSNotification) {
        let userInfo:Dictionary<String,NSData!> = notification.userInfo as! Dictionary<String,NSData!>
        let data = userInfo["strokeInfo"]
        
        var strokeInfo: Keystroke = Keystroke()
        data!.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        switch strokeInfo.interactionType! {
        case .Trackpad:
            
            switch strokeInfo.trackpadType! {
                
            case .Movement:
                
                switch strokeInfo.gestureType! {
                case .Tap:
                    break;
                case .Pan:
                    
                    if strokeInfo.panTranslation != nil {
                        
                        // First check if the pan had just started
                        if strokeInfo.panStart == true {
                            oldPosition = sprite!.presentationNode.position
                            oldCameraPosition = camera!.presentationNode.position
                        }
                        
                        // Calculate the amount changed rather than concatenating
                        
                        newPosition = SCNVector3(x: oldPosition.x+strokeInfo.panTranslation!.x, y: oldPosition.y, z: oldPosition.z+strokeInfo.panTranslation!.y)
                        
                        sprite!.position = SCNVector3(x: oldPosition.x+strokeInfo.panTranslation!.x, y: oldPosition.y, z: oldPosition.z+strokeInfo.panTranslation!.y)
                        
                        newCameraPosition = SCNVector3(x: oldCameraPosition.x+strokeInfo.panTranslation!.x, y: oldCameraPosition.y, z: oldCameraPosition.z+strokeInfo.panTranslation!.y)
                        
                    }
                }
            case .Camera:
                
                switch strokeInfo.gestureType! {
                case .Tap:
                    break;
                case .Pan:
                    
                    // First check if the pan had just started
                    if strokeInfo.panStart == true {
                        oldCameraRotation = self.camera.presentationNode.eulerAngles
                    }
                    
                    // Change camera view
                    if strokeInfo.panTranslation != nil {
                        var newYaw = (Float)(strokeInfo.panTranslation!.x)*(Float)(M_PI)/180.0
                        newYaw += Float(oldCameraRotation.x)
                        var newPitch = (Float)(strokeInfo.panTranslation!.y)*(Float)(M_PI)/180.0
                        newPitch += Float(oldCameraRotation.y)
                        
                        // Use euler angles
                        newCameraRotation = SCNVector3(-newPitch, -newYaw, Float(self.camera.presentationNode.eulerAngles.z))
                        
                        self.camera.eulerAngles = newCameraRotation!
                        
                    } else {
                        oldCameraRotation = newCameraRotation
                    }
                }
            }
        case .Button:
            print("it was a button event")
            
            switch strokeInfo.button! {
            case .Crouch:
                print("the button event was crouch")
            case .Jump:
                print("the button event was jump")
                sprite.physicsBody?.applyForce(SCNVector3(x: sprite.position.x, y: sprite.position.y+7, z: sprite.position.z), atPosition: sprite.position, impulse: true)
            case .Attack:
                print ("the button event was attack")
            case .Interact:
                print ("the button event was interact")
            }
        }
        
    }
}

extension GameViewController : SCNSceneRendererDelegate {
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // add code
//        if let changedPosition = newPosition {
//            sprite!.position = changedPosition
//        }
//        if let changedCameraRotation = newCameraRotation {
//            camera.eulerAngles = changedCameraRotation
//        }
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        // add code
    }
    
    func renderer(renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // Add code
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // add code
    }
}

extension GameViewController : SCNPhysicsContactDelegate {
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        // add code
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        // add code
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        // add code
    }
}
