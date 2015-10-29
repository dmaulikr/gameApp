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
    static let Player = 0x1 << 0
    static let Enemy = 0x1 << 1
    static let Ground = 0x1 << 2
    static let Weapon = 0x1 << 3
    static let Bullet = 0x1 << 4
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
    var enemy: Enemy!
    var camera: Camera!
    var weapon: Weapon!
    var ground: SCNNode!
    var light: SCNNode!
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
        //sceneView.scene = SCNScene(named: "art.scnassets/level.scn")
        sceneView.scene?.physicsWorld.contactDelegate = self
        sceneView.playing = true
        sceneView.delegate = self
        
        let islandScene = SCNScene(named: "art.scnassets/Small Tropical Island/Untitled.dae")
        let nodeArray = islandScene!.rootNode.childNodes
        
        let islandNode = SCNNode()
        islandNode.position = SCNVector3Make(0, 0, -450)
        
        for childNode in nodeArray {
            
            // Add model as child node
            islandNode.addChildNode(childNode)
        }
        let shape = SCNPhysicsShape(node: islandNode, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron, SCNPhysicsShapeKeepAsCompoundKey: false]);
        islandNode.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
        islandNode.physicsBody?.categoryBitMask = ColliderType.Ground
        islandNode.physicsBody?.collisionBitMask = ColliderType.Bullet | ColliderType.Enemy | ColliderType.Player
        sceneView.scene?.rootNode.addChildNode(islandNode)
        
        // Needs to be initialized in main queue
        dispatch_async(dispatch_get_main_queue(), {
        // Add SKScene to function like a HUD
        self.hud = HUD(size: self.sceneView.bounds.size)
        self.sceneView.overlaySKScene = self.hud
        })
        
        self.view.addSubview(self.sceneView);
        
        
        // create ground
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        //let groundMaterial = SCNMaterial()
        //groundMaterial.diffuse.contents = NSColor.lightGrayColor()
        groundGeometry.firstMaterial!.diffuse.contents = "art.scnassets/Grass_1.png"
        groundGeometry.firstMaterial!.locksAmbientWithDiffuse = true
        //groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        ground.physicsBody = SCNPhysicsBody(type: .Static, shape: groundShape)
        ground.physicsBody?.categoryBitMask = ColliderType.Ground
        
        
        // create character
        sprite = Player()
        sprite.position = SCNVector3Make(0, 0, 0)
        
        // create and add a camera to the scene
        self.camera = Camera()
        self.camera.position = SCNVector3(x: 0, y: sprite.height, z: sprite.length/2) // over-the-shoulder view
        sprite.addChildNode(self.camera)
        
        // create weapon
        weapon = WeaponFactory.createHandgun()
        camera.addChildNode(weapon)
        sprite.equippedWeapon = weapon
    
        // create enemy
        enemy = EnemyFactory.createCombatAndroid(SCNVector3Make(-25, 0, -40))
        sceneView.scene?.rootNode.addChildNode(enemy)
        
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
                        let horizontalAngle = acos(normalizedVector.dx / 70) - CGFloat(M_PI_2)
                        let verticalAngle = acos(normalizedVector.dy / 70) - CGFloat(M_PI_2)
                        
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
            switch strokeInfo.button! {
            case .Crouch:
                print("the button event was crouch")
            case .Attack:
                
                // first get camera position in terms of the scene
                let cameraPositionInRoot = sceneView.scene?.rootNode.convertPosition(camera.presentationNode.position, fromNode: sprite)
                
                let cameraFacingRootCoordinates = sceneView.scene?.rootNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: camera)
                
                let cameraFacingDirectionVector = SCNVector3Make(cameraFacingRootCoordinates!.x-cameraPositionInRoot!.x, (cameraFacingRootCoordinates!.y-cameraPositionInRoot!.y)*2, cameraFacingRootCoordinates!.z-cameraPositionInRoot!.z)

                shootingDirectionVector = getNormalizedVector(cameraFacingDirectionVector)
                
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
        camera.transform = SCNMatrix4Mult(oldVerticalRotation!, verticalRotation!)
        
        oldHorizontalRotation = sprite.transform
        oldVerticalRotation = camera.transform
    }
    
    func updateCrosshairAim(){
        
        if fired == true {
        let bulletGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
        let bulletMaterial = SCNMaterial()
        bulletMaterial.diffuse.contents = NSColor.orangeColor()
        bulletGeometry.materials = [bulletMaterial]
        bullet = SCNNode(geometry: bulletGeometry)
        bullet!.position = sceneView.scene!.rootNode.convertPosition(camera.presentationNode.position, fromNode: sprite)
        bullet!.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
        bullet!.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
        bullet!.physicsBody?.categoryBitMask = ColliderType.Bullet
        bullet!.physicsBody?.collisionBitMask = ColliderType.Enemy | ColliderType.Player | ColliderType.Ground
        sceneView.scene?.rootNode.addChildNode(bullet!)
            
        let impulse = SCNVector3Make(shootingDirectionVector!.x*300, shootingDirectionVector!.y*300, shootingDirectionVector!.z*300)
        
        bullet!.physicsBody?.applyForce(impulse, impulse: true)
        
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
        
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        switch contactMask {
        case ColliderType.Player | ColliderType.Enemy:
            print("collision between player and enemy")
        case ColliderType.Player | ColliderType.Bullet:
            print("collision between player and bullet")
            
            // calculate the damage to the player
            
        case ColliderType.Weapon | ColliderType.Enemy:
            print("collision between weapon and enemy")
        case ColliderType.Bullet | ColliderType.Enemy:
            bullet?.removeFromParentNode()
            print("collision between bullet and enemy")
            print("old enemy life: \(enemy.health)")
            enemy.health! -= sprite.equippedWeapon!.baseDamage!
            print("new enemy life: \(enemy.health)")
            
            // calculate the damage to the enemy
            
        case ColliderType.Bullet | ColliderType.Ground:
            bullet?.removeFromParentNode()
        default: break
        }
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        // add code
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        // add code
    }
}
