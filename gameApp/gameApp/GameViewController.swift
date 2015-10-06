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
    var cameraOrbit: SCNNode!
    var ground: SCNNode!
    var light: SCNNode!
    var sprite: SCNNode!
    
    var oldPosition: SCNVector3!
    var newPosition: SCNVector3?
    var oldCameraPosition: SCNVector3!
    var newCameraPosition: SCNVector3?
    var oldCameraRotation: SCNVector3!
    var newCameraRotation: SCNVector3?
    var oldCameraOrbitEuler: SCNVector3!
    var newCameraOrbitEuler: SCNVector3?
    var movementDirectionVector: SCNVector3?
    
    var movementTrackpadInUse: Bool!
    
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
        let bodyShape = SCNPhysicsShape(geometry: spriteGeometry, options: nil)
        sprite.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: bodyShape)
        
        // create random bots to test for movement in distance
        let bot1Geometry = SCNBox(width: 15, height: 15, length: 15, chamferRadius: 1)
        let bot1Material = SCNMaterial()
        bot1Material.diffuse.contents = NSColor.redColor()
        bot1Geometry.materials = [bot1Material]
        let bot1 = SCNNode(geometry: bot1Geometry)
        bot1.position = SCNVector3(x: -25, y: 0, z: -40)
        
        let bot2Geometry = SCNBox(width: 15, height: 15, length: 15, chamferRadius: 1)
        let bot2Material = SCNMaterial()
        bot2Material.diffuse.contents = NSColor.greenColor()
        bot2Geometry.materials = [bot2Material]
        let bot2 = SCNNode(geometry: bot2Geometry)
        bot2.position = SCNVector3(x: 25, y: 0, z: 60)
        
        
        // create and add a camera to the scene
        let camera = SCNCamera()
        camera.zFar = 1_000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: 0, y: 17, z: 30) // over-the-shoulder view
        cameraOrbit = SCNNode()
        cameraOrbit.position = sprite!.position
        cameraOrbit.addChildNode(self.camera)
        
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
        let constraint = SCNLookAtConstraint(target: sprite)
        light.constraints = [constraint]
        
        // add physics
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .Kinematic, shape: groundShape)
        ground.physicsBody = groundBody
        
        let spriteShape = SCNPhysicsShape(geometry: sprite.geometry!, options: nil)
        let spriteBody = SCNPhysicsBody(type: .Kinematic, shape: spriteShape)
        sprite.physicsBody = spriteBody
        
        sceneView.scene?.rootNode.addChildNode(self.cameraOrbit)
        sceneView.scene?.rootNode.addChildNode(light)
        sceneView.scene?.rootNode.addChildNode(ground)
        sceneView.scene?.rootNode.addChildNode(sprite)
        sceneView.scene?.rootNode.addChildNode(bot1)
        sceneView.scene?.rootNode.addChildNode(bot2)
        
        sceneView.showsStatistics = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerControls:", name: kPlayerControlsNK, object: nil)
        
        oldCameraRotation = self.camera.eulerAngles
        oldCameraOrbitEuler = self.cameraOrbit.eulerAngles
        
        movementDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        movementTrackpadInUse = false
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
                        
                        // convert coordinate systems
                        let panx = strokeInfo.panTranslation!.x
                        let pany = -strokeInfo.panTranslation!.y
                        
                        // Where
                        /***********
                        positive panx is a swipe right
                        negative panx is a swipe left
                        positive pany is a swipe up
                        negative pany is a swipe down
                        ************/
                        
                        // First check if the pan had just started
                        if strokeInfo.panStart == true {
                            oldPosition = sprite.presentationNode.position
                            movementTrackpadInUse = true
                        }
                        
                        // Rotates the sprites in the direction they are moving
                        sprite.eulerAngles = SCNVector3(x: 0, y: cameraOrbit.eulerAngles.y, z: 0)
                        
                         // first check if the pan is even significant
                        if abs(panx) > 20 || abs(pany) > 20 {
                        
                        // Get the coordinate point in the scene of the forward facing sprite
                        let forwardFacingSceneCoordinates = sceneView.scene?.rootNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: cameraOrbit)
                        
                        // Get the forward movement direction vector
                        let forwardMovementDirection = SCNVector3(x: forwardFacingSceneCoordinates!.x - cameraOrbit.position.x, y: forwardFacingSceneCoordinates!.y - cameraOrbit.position.y, z: forwardFacingSceneCoordinates!.z - cameraOrbit.position.z)
                        
                        if abs(forwardMovementDirection.z) > abs(forwardMovementDirection.x) {
                            // z is the general forward direction
                            if forwardMovementDirection.z < 0 {
                                // moving forward (-z) in terms of rootNode coordinate space
                                newPosition = SCNVector3(x: oldPosition.x+panx, y: oldPosition!.y, z: oldPosition.z+(-pany))
                                
                                // Get normalized vector to just get direction
                                
                                // First get vector magnitude
                                let vector = SCNVector3Make(panx, 0, -pany)
                                 movementDirectionVector = getNormalizedVector(vector)
                                
                            } else {
                                // moving backward (+z) in terms of rootNode coordinate space
                                newPosition = SCNVector3(x: oldPosition.x+(-panx), y: oldPosition!.y, z: oldPosition.z+pany)
                                
                                let vector = SCNVector3Make(-panx, 0, pany)
                                movementDirectionVector = getNormalizedVector(vector)

                            }
                        } else {
                            // x is the general forward direction
                            if forwardMovementDirection.x < 0 {
                                newPosition = SCNVector3(x: oldPosition.x+(-pany), y: oldPosition!.y, z: oldPosition.z+(-panx))
                                
                                let vector = SCNVector3Make(-pany, 0, -panx)
                                movementDirectionVector = getNormalizedVector(vector)
                                
                            } else {
                                newPosition = SCNVector3(x: oldPosition.x+pany, y: oldPosition!.y, z: oldPosition.z+panx)
                                
                                let vector = SCNVector3Make(pany, 0, panx)
                                movementDirectionVector = getNormalizedVector(vector)
                            }
                        }
                        } else {
                            // pan gesture not significant
                            movementDirectionVector = SCNVector3Make(0, 0, 0)
                        }
                        
                    } else {
                        movementTrackpadInUse = false
                    }
                }
            case .Camera:
                
                switch strokeInfo.gestureType! {
                case .Tap:
                    sprite.physicsBody?.applyForce(SCNVector3(x: sprite.position.x, y: sprite.position.y+7, z: sprite.position.z), atPosition: sprite.position, impulse: true)
                case .Pan:
                    
                    // Change camera view
                    if strokeInfo.panTranslation != nil {
                        
                        // First check if the pan had just started
                        if strokeInfo.panStart == true {
                            //print("Camera pan has just started")
                            oldCameraRotation = self.camera.presentationNode.eulerAngles
                            //oldCameraOrbitEuler = self.cameraOrbit.presentationNode.eulerAngles
                            oldCameraOrbitEuler = SCNVector3(0, 0 ,0)
                            //print("oldCameraOrbitEuler: \(oldCameraOrbitEuler)")
                        }
                        
                        // here rotate the camera orbit (this is left and right)
                        var newYaw = (Float)(strokeInfo.panTranslation!.x)*(Float)(M_PI)/180.0
                        newYaw += Float(oldCameraOrbitEuler.x)
                        
                        // here rotate the actual camera up and down
                        var newPitch = (Float)(strokeInfo.panTranslation!.y)*(Float)(M_PI)/180.0
                        newPitch += Float(oldCameraOrbitEuler.y)
                        
                        //newCameraOrbitEuler = SCNVector3(-newPitch+Float(oldCameraOrbitEuler.x), -newYaw+Float(oldCameraOrbitEuler.y), Float(oldCameraOrbitEuler.z))
                        //newCameraOrbitEuler = SCNVector3(-newPitch, -newYaw, Float(oldCameraOrbitEuler.z))
                        
                        newCameraOrbitEuler = SCNVector3(-newPitch, -newYaw, 0)
                        // Rotates the sprites in the direction the camera is facing
                        sprite.eulerAngles = SCNVector3(x: 0, y: cameraOrbit.eulerAngles.y, z: 0)
                        //print("newCameraOrbitEuler: \(newCameraOrbitEuler)")
                    } else {
                        //print("Camera pan has just ended")
                        // pan has just ended
                        oldCameraOrbitEuler = self.cameraOrbit.presentationNode.eulerAngles
                        //print("oldCameraOrbitEuler: \(oldCameraOrbitEuler)")
                    }
                }
            }
        case .Button:
            print("it was a button event")
            
            switch strokeInfo.button! {
            case .Crouch:
                print("the button event was crouch")
            case .Attack:
                print ("the button event was attack")
            case .Interact:
                print ("the button event was interact")
            }
        }
        
    }
    
    func getNormalizedVector(vector: SCNVector3) -> SCNVector3 {
        
        let vectorMagnitude = sqrtf(Float(vector.x*vector.x)+Float(vector.y*vector.y)+Float(vector.z*vector.z))
        let normalizedVector = SCNVector3Make(vector.x/CGFloat(vectorMagnitude), vector.y/CGFloat(vectorMagnitude), vector.z/CGFloat(vectorMagnitude))
        return normalizedVector
    }
}

extension GameViewController : SCNSceneRendererDelegate {
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // add code
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        // add code
    }
    
    func renderer(renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // Add code
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // add code
        
        if movementTrackpadInUse == true {
            let playerSpeed:CGFloat = 0.7
            sprite!.position = SCNVector3(sprite.presentationNode.position.x + movementDirectionVector!.x*playerSpeed, sprite.presentationNode.position.y + movementDirectionVector!.y*playerSpeed, sprite.presentationNode.position.z + movementDirectionVector!.z*playerSpeed)
            cameraOrbit!.position = sprite!.position
            sprite.eulerAngles = SCNVector3(x: 0, y: cameraOrbit.eulerAngles.y, z: 0)
        }
        
//        if let changedPosition = newPosition {
//            sprite!.position = changedPosition
//            cameraOrbit!.position = sprite!.position
//        }
        
        //        if let changedCameraRotation = newCameraRotation {
        //            self.camera.eulerAngles = changedCameraRotation
        //        }
        
        if let changedCameraOrbitEuler = newCameraOrbitEuler {
            //First convert the camera's position to that of the scene
            
            if changedCameraOrbitEuler.x < 0.7 {
                self.cameraOrbit.eulerAngles = changedCameraOrbitEuler
                sprite.eulerAngles = SCNVector3(x: 0, y: cameraOrbit.eulerAngles.y, z: 0)
            } else {
                // only update the y values since the x values will be too low
                self.cameraOrbit.eulerAngles.y = changedCameraOrbitEuler.y
                sprite.eulerAngles = SCNVector3(x: 0, y: cameraOrbit.eulerAngles.y, z: 0)
            }
            
        }
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
