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

struct ColliderType {
    static let Player = 0b1
    static let Bot1 = 0b10
    static let Bot2 = 0b100
    static let Ground = 0b1000
    static let Weapon = 0b10000
    static let Bullet = 0b100000
}

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
    var hud: HUD!
    var sprite: Player!
    var camera: Camera!
    var ground: SCNNode!
    var light: SCNNode!
    var weapon: SCNNode!
    var bullet: SCNNode?
    
    var movementDirectionVector: SCNVector3?
    var shootingDirectionVector: SCNVector3?
    var bulletStart: SCNVector3?
    
    var oldHorizontalRotation: SCNMatrix4?
    var oldVerticalRotation: SCNMatrix4?
    
    var horizontalRotation: SCNMatrix4?
    var verticalRotation: SCNMatrix4?
    
    var fired: Bool?
    
    override func awakeFromNib(){
        // create a new scene
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.scene?.physicsWorld.contactDelegate = self
        sceneView.playing = true
        sceneView.delegate = self
        
        // Add SKScene to function like a HUD
        hud = HUD(size: sceneView.bounds.size)
        
        // Needs to be initialized in main queue
        dispatch_async(dispatch_get_main_queue(), {
        self.sceneView.overlaySKScene = self.hud
        })
        
        self.view.addSubview(sceneView);
        
        
        // create ground
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = NSColor.lightGrayColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        ground.physicsBody = SCNPhysicsBody(type: .Static, shape: groundShape)
        ground.categoryBitMask = ColliderType.Ground
        
        // create character
        sprite = Player()
        sprite.position = SCNVector3Make(0, 2, 0)
        
        // create random bots to test for movement in distance
        let bot1Geometry = SCNBox(width: 15, height: 15, length: 15, chamferRadius: 1)
        let bot1Material = SCNMaterial()
        bot1Material.diffuse.contents = NSColor.redColor()
        bot1Geometry.materials = [bot1Material]
        let bot1 = SCNNode(geometry: bot1Geometry)
        bot1.position = SCNVector3(x: -25, y: 10, z: -40)
        let bot1Shape = SCNPhysicsShape(geometry: bot1Geometry, options: nil)
        bot1.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: bot1Shape)
        bot1.categoryBitMask = ColliderType.Bot1
        bot1.physicsBody!.categoryBitMask = ColliderType.Bot1
        bot1.physicsBody!.collisionBitMask = ColliderType.Player | ColliderType.Ground | ColliderType.Weapon
        
        let bot2Geometry = SCNBox(width: 15, height: 15, length: 15, chamferRadius: 1)
        let bot2Material = SCNMaterial()
        bot2Material.diffuse.contents = NSColor.greenColor()
        bot2Geometry.materials = [bot2Material]
        let bot2 = SCNNode(geometry: bot2Geometry)
        bot2.position = SCNVector3(x: 25, y: 10, z: 60)
        let bot2Shape = SCNPhysicsShape(geometry: bot2Geometry, options: nil)
        bot2.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: bot2Shape)
        bot2.physicsBody!.categoryBitMask = ColliderType.Bot2
        bot2.physicsBody!.collisionBitMask = ColliderType.Player | ColliderType.Ground | ColliderType.Weapon
        
        // create and add a camera to the scene
        self.camera = Camera()
        self.camera.position = SCNVector3(x: 0, y: sprite.height, z: sprite.length/2) // over-the-shoulder view
        sprite.addChildNode(self.camera)
        
        // create weapon
        let weaponScene = SCNScene(named: "art.scnassets/Handgun.dae")
        let nodeArray = weaponScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            weapon = childNode
            weapon.position = SCNVector3Make(1, -3, -3)
            let weaponGeometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 1)
            let weaponShape = SCNPhysicsShape(geometry: weaponGeometry, options: nil)
            weapon.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: weaponShape)
            weapon.physicsBody?.categoryBitMask = ColliderType.Weapon
            weapon.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Bot1 | ColliderType.Bot2
            camera.addChildNode(weapon)
        }
        
        // add lighting
        let ambientLight = SCNLight()
        ambientLight.color = NSColor.lightGrayColor()
        ambientLight.type = SCNLightTypeAmbient
        self.camera.light = ambientLight  // Add ambient lighting to the camera
        
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.castsShadow = true
        spotLight.zFar = 30
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        let constraint = SCNLookAtConstraint(target: sprite)
        light.constraints = [constraint]
        
        sceneView.scene?.rootNode.addChildNode(light)
        sceneView.scene?.rootNode.addChildNode(ground)
        sceneView.scene?.rootNode.addChildNode(sprite)
        sceneView.scene?.rootNode.addChildNode(bot1)
        sceneView.scene?.rootNode.addChildNode(bot2)
        
        sceneView.showsStatistics = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerControls:", name: kPlayerControlsNK, object: nil)
        
        movementDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        shootingDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        bulletStart = SCNVector3Make(0, 0, 0)
        
        horizontalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldHorizontalRotation = sprite.transform
        oldVerticalRotation = self.camera.transform
        
        fired = false
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
                        
                        // first check if the pan is even significant
                        if abs(panx) > 15 || abs(pany) > 15 {
                            
                            self.setMovementDirection(self.forwardMovementDirectionVector(), panx: panx, pany: pany)
                            
                        } else {
                            // pan gesture not significant
                            movementDirectionVector = SCNVector3Make(0, 0, 0)
                        }
                        
                    } else {
                        movementDirectionVector = SCNVector3Make(0, 0, 0) // We are not moving so vector must be nil
                    }
                }
            case .Camera:
                switch strokeInfo.gestureType! {
                case .Tap:
                    sprite.physicsBody?.applyForce(SCNVector3Make(0, sprite.jumpHeight, 0), impulse: true)
                case .Pan:
                    
                    // Change camera view
                    if strokeInfo.panTranslation != nil {
                        
                        // First generate a vector from the translation points
                        let panVector = CGVectorMake(strokeInfo.panTranslation!.x, strokeInfo.panTranslation!.y)
                        
                        // Normalize vector to make sure the speed of rotation stays constant
                        let vectorMagnitude = sqrtf(Float(panVector.dx*panVector.dx)+Float(panVector.dy*panVector.dy))
                        let normalizedVector = CGVectorMake(panVector.dx/CGFloat(vectorMagnitude), panVector.dy/CGFloat(vectorMagnitude))
                        
                        // Generate angles based on the normalized vector
                        let horizontalAngle = acos(normalizedVector.dx / 55) - CGFloat(M_PI_2)
                        let verticalAngle = acos(normalizedVector.dy / 55) - CGFloat(M_PI_2)
                        
                        // Create a matrix that represents the horizontal rotation
                        horizontalRotation = SCNMatrix4MakeRotation(CGFloat(horizontalAngle), 0, 1, 0)
                        
                        
                        // First check if camera rotation is valid
                        if self.cameraRotationValid(CGFloat(verticalAngle)) == true {
                            verticalRotation = SCNMatrix4MakeRotation(CGFloat(verticalAngle), 1, 0, 0)
                        } else {
                            verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
                        }
                        
                    } else {
                        // No rotations must happen anymore
                        horizontalRotation = SCNMatrix4Identity
                        verticalRotation = SCNMatrix4Identity
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
                
                // Create a vector based on the bullet direction
                
                // First get camera position. This is the bullet starting point
                bulletStart = self.camera.presentationNode.position
                
                // Then get the sprite facing direction. This will have the correct x and z values
                // Already normalized
                let forwardDirection = self.forwardMovementDirectionVector()
                
                // Use tan(ø) = opp/adj
                var crosshairY: CGFloat!
                // Now calculate the y value
                if camera.rotation.x > 0 {
                    //crosshair pointing up
                    print("crosshair pointing up")
                    print("cameraRotation: \(camera.rotation.x)")
                    crosshairY = tan(camera.rotation.x)
                    
                } else {
                    // crosshair pointing down
                    print("crosshair pointing down")
                    print("cameraRotation: \(camera.rotation.x)")
                    crosshairY = tan(camera.rotation.x)
                    crosshairY = -crosshairY
                }
                //let yCrosshairPosition = camera.presentationNode.position.y+crosshairY
                //shootingDirectionVector = getNormalizedVector(SCNVector3Make(forwardDirection.x-bulletStart.x, yCrosshairPosition-bulletStart.y, forwardDirection.z-bulletStart.z))
                
                bulletStart!.y += crosshairY
                print("bulletStartY: \(bulletStart)")
                shootingDirectionVector = getNormalizedVector(SCNVector3Make(forwardDirection.x-bulletStart!.x, 0, forwardDirection.z-bulletStart!.z))
                
                fired = true
                
            case .Interact:
                print ("the button event was interact")
            }
        }
    }
    
    func forwardMovementDirectionVector() -> SCNVector3 {
        // converts sprite's forward facing coordinate system into that of the sceneView rootNode
        let forwardFacingSceneCoordinates = sceneView.scene?.rootNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: sprite)
        
        // Get the forward movement direction vector
        let forwardMovementDirection = SCNVector3(x: forwardFacingSceneCoordinates!.x - sprite.presentationNode.position.x, y: forwardFacingSceneCoordinates!.y - sprite.presentationNode.position.y, z: forwardFacingSceneCoordinates!.z - sprite.presentationNode.position.z)
        
        return forwardMovementDirection
    }
    
    func setMovementDirection(facingVector: SCNVector3, panx: CGFloat, pany: CGFloat) {
        if abs(facingVector.z) > abs(facingVector.x) {
            // z is the general forward direction
            if facingVector.z < 0 {
                // moving forward (-z) in terms of rootNode coordinate space
                let vector = SCNVector3Make(panx, 0, -pany)
                movementDirectionVector = getNormalizedVector(vector)
            } else {
                // moving backward (+z) in terms of rootNode coordinate space
                let vector = SCNVector3Make(-panx, 0, pany)
                movementDirectionVector = getNormalizedVector(vector)
            }
        } else {
            // x is the general forward direction
            if facingVector.x < 0 {
                let vector = SCNVector3Make(-pany, 0, -panx)
                movementDirectionVector = getNormalizedVector(vector)
            } else {
                let vector = SCNVector3Make(pany, 0, panx)
                movementDirectionVector = getNormalizedVector(vector)
            }
        }
    }
    
    func getNormalizedVector(vector: SCNVector3) -> SCNVector3 {
        let vectorMagnitude = sqrtf(Float(vector.x*vector.x)+Float(vector.y*vector.y)+Float(vector.z*vector.z))
        let normalizedVector = SCNVector3Make(vector.x/CGFloat(vectorMagnitude), vector.y/CGFloat(vectorMagnitude), vector.z/CGFloat(vectorMagnitude))
        return normalizedVector
    }
    
    func cameraRotationValid(angle: CGFloat) -> Bool {
        var cameraAngle: CGFloat
        if camera.rotation.x > 0 {
            cameraAngle = camera.rotation.w
        } else {
            cameraAngle = -camera.rotation.w
        }
        
        if cameraAngle + angle < CGFloat(M_PI_2) && cameraAngle + angle > CGFloat(-M_PI_2) {
            return true
        } else {
            return false
        }
    }
    
    func updateSpriteTransform() {
        // First take care of rotation
        var spriteTransform = SCNMatrix4Mult(oldHorizontalRotation!, horizontalRotation!)
        
        // Then take care of translation
        spriteTransform.m41 = sprite.presentationNode.position.x + movementDirectionVector!.x*sprite.speed
        spriteTransform.m42 = sprite.presentationNode.position.y + movementDirectionVector!.y*sprite.speed
        spriteTransform.m43 = sprite.presentationNode.position.z + movementDirectionVector!.z*sprite.speed
        spriteTransform.m44 = 1.0
        
        // Set sprite transform
        sprite.transform = spriteTransform
        
        // Set camera transform
        camera.transform = SCNMatrix4Mult(oldVerticalRotation!, verticalRotation!)
        
        oldHorizontalRotation = sprite.transform
        oldVerticalRotation = camera.transform
    }
    
    func updateCrosshairAim(){
        
        if fired == true {
        print("bulletStart: \(bulletStart)")
        print("shootingDirectionVector: \(shootingDirectionVector)")
        
        let bulletGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
        let bulletMaterial = SCNMaterial()
        bulletMaterial.diffuse.contents = NSColor.orangeColor()
        bulletGeometry.materials = [bulletMaterial]
        let bullet = SCNNode(geometry: bulletGeometry)
        bullet.position = bulletStart!
        bullet.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
        bullet.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
        sceneView.scene?.rootNode.addChildNode(bullet)
            
        let impulse = SCNVector3Make(shootingDirectionVector!.x*100, shootingDirectionVector!.y*100, shootingDirectionVector!.z*100)
        print("impulse: \(impulse)")
        
        bullet.physicsBody?.applyForce(impulse, impulse: true)
        
        fired = false
        }
    }
}

extension GameViewController : SCNSceneRendererDelegate {
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // add code
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        self.updateSpriteTransform()
        self.updateCrosshairAim()
    }
    
    func renderer(renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // Add code
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // Add code
    }
}

extension GameViewController : SCNPhysicsContactDelegate {
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        var firstBody: SCNNode
        var secondBody: SCNNode
        
        if contact.nodeA.categoryBitMask < contact.nodeB.categoryBitMask {
            firstBody = contact.nodeA
            secondBody = contact.nodeB
        } else {
            firstBody = contact.nodeB
            secondBody = contact.nodeA
        }
        
        if ((firstBody.categoryBitMask & ColliderType.Player) != 0) && ((secondBody.categoryBitMask & ColliderType.Bot1) != 0) {
            print("collision was between player and bot1")
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        // add code
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        // add code
    }
}
