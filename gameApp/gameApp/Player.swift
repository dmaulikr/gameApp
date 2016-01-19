//
//  Player.swift
//  gameApp
//
//  Created by Liza Girsova on 10/11/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Player: SCNNode {
    
    enum ID {
        case ID1
        case ID2
    }
    
    var id: ID?
    var levelNode: SCNNode!
    let width: CGFloat = 5
    let height: CGFloat = 12
    let length: CGFloat = 2
    let speed: CGFloat = 1.0
    let jumpHeight: CGFloat = 10
    var health: CGFloat = 100
    let damage: CGFloat = 5
    var equippedWeapon: Weapon?
    var startedEnemyContact: Bool!
    
    var gruntAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/male-grunt.wav")!
    
    var movementDirectionVector: SCNVector3?
    var shootingDirectionVector: SCNVector3?
    var bulletStart: SCNVector3?
    
    var oldHorizontalRotation: SCNMatrix4?
    var oldVerticalRotation: SCNMatrix4?
    
    var horizontalRotation: SCNMatrix4?
    var verticalRotation: SCNMatrix4?
    
    var fired: Bool?
    
    init(playerId: Player.ID, levelNode: SCNNode!) {
        // Initialize player
        self.id = playerId
        self.levelNode = levelNode
        super.init()
        let geometry = SCNBox(width: self.width, height: self.height, length: self.length, chamferRadius: 0)
        let material = SCNMaterial()
        if self.id == Player.ID.ID1 {
            material.diffuse.contents = NSColor.blueColor()
        } else {
            material.diffuse.contents = NSColor.greenColor()
        }
        geometry.materials = [material]
        self.geometry = geometry
        
        // Set player physics
        let bodyShape = SCNPhysicsShape(geometry: geometry, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: bodyShape)
        self.physicsBody?.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0)
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Wall | ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.friction = 0.7
        self.physicsBody?.restitution = 0 // does not bounce during collisions
        
        horizontalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldHorizontalRotation = self.transform
        verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldVerticalRotation = self.transform
        movementDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        startedEnemyContact = false
        
        gruntAudioSource.load()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func calculateMovementTransform(panx: CGFloat, pany: CGFloat) {
        // convert coordinate systems
        let panx = panx
        let pany = -pany
        
        // Where
        /***********
        positive panx is a swipe right
        negative panx is a swipe left
        positive pany is a swipe up
        negative pany is a swipe down
        ************/
        
        // first check if the pan is even significant
        if abs(panx) > 5 || abs(pany) > 5 {
            self.setMovementDirection(self.forwardMovementDirectionVector(), panx: panx, pany: pany)
        } else {
            // pan gesture not significant
            movementDirectionVector = SCNVector3Make(0, 0, 0)
        }
    }
    
    func setMovementDirection(facingVector: SCNVector3, panx: CGFloat, pany: CGFloat) {
        if abs(facingVector.z) > abs(facingVector.x) {
            // z is the general forward direction
            if facingVector.z < 0 {
                // moving forward (-z) in terms of rootNode coordinate space
                let vector = SCNVector3Make(panx, 0, -pany)
                movementDirectionVector = VectorMath.getNormalizedVector(vector)
            } else {
                // moving backward (+z) in terms of rootNode coordinate space
                let vector = SCNVector3Make(-panx, 0, pany)
                movementDirectionVector = VectorMath.getNormalizedVector(vector)
            }
        } else {
            // x is the general forward direction
            if facingVector.x < 0 {
                let vector = SCNVector3Make(-pany, 0, -panx)
                movementDirectionVector = VectorMath.getNormalizedVector(vector)
            } else {
                let vector = SCNVector3Make(pany, 0, panx)
                movementDirectionVector = VectorMath.getNormalizedVector(vector)
            }
        }
    }
    
    func updatePlayerTransform() {
        // First take care of rotation
        var playerTransform = SCNMatrix4Mult(oldHorizontalRotation!, horizontalRotation!)
        
        // Then take care of translation
        playerTransform.m41 = self.presentationNode.position.x + movementDirectionVector!.x*self.speed
        playerTransform.m42 = self.presentationNode.position.y + movementDirectionVector!.y*self.speed
        playerTransform.m43 = self.presentationNode.position.z + movementDirectionVector!.z*self.speed
        playerTransform.m44 = 1.0
        
        // Set player transform
        self.transform = playerTransform
        ownCameraNode().transform = SCNMatrix4Mult(oldVerticalRotation!, verticalRotation!)
        //ownCamera!.updateTransform()
        
        oldHorizontalRotation = self.transform
        oldVerticalRotation = ownCameraNode().transform
    }
    
    func calculateRotationTransform(panx: CGFloat, pany: CGFloat) {
        // First generate a vector from the translation points
        let panVector = CGVectorMake(panx, pany)
        
        // Normalize vector to make sure the speed of rotation stays constant
        let normalizedPanVector = VectorMath.getNormalizedVector(panVector)
        
        let panVectorMag = VectorMath.getVectorMagnitude(panVector)
        
        let horizontalAngle: CGFloat
        let verticalAngle: CGFloat
        if panVectorMag > 50 {
            // Generate angles based on the normalized vector
            horizontalAngle = acos(normalizedPanVector.dx / 50) - CGFloat(M_PI_2)
            verticalAngle = acos(normalizedPanVector.dy / 50) - CGFloat(M_PI_2)
        } else if panVectorMag > 30{
            horizontalAngle = acos(normalizedPanVector.dx / 85) - CGFloat(M_PI_2)
            verticalAngle = acos(normalizedPanVector.dy / 85) - CGFloat(M_PI_2)
        } else {
            horizontalAngle = acos(normalizedPanVector.dx / 140) - CGFloat(M_PI_2)
            verticalAngle = acos(normalizedPanVector.dy / 140) - CGFloat(M_PI_2)
        }
        
        // Create a matrix that represents the horizontal rotation
        self.horizontalRotation = SCNMatrix4MakeRotation(CGFloat(horizontalAngle), 0, 1, 0)
        
        
        // First check if camera rotation is valid
        if ownCameraNode().cameraRotationValid(CGFloat(verticalAngle)) == true {
            self.verticalRotation = SCNMatrix4MakeRotation(CGFloat(verticalAngle), 1, 0, 0)
        } else {
            self.verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        }
    }
    
    func updateCrosshairAim(){
        if fired == true {
            equippedWeapon?.fire(shootingDirectionVector!)
            fired = false
        }
    }
    
    func playerNotMoving() {
        movementDirectionVector = SCNVector3Make(0, 0, 0)
    }

    func subtractPlayerHealth(damage: CGFloat) {
        self.health -= damage
        
        let gruntAction = SCNAction.playAudioSource(gruntAudioSource, waitForCompletion: false)
        self.runAction(gruntAction)
        
        // Send notification to HUD to subtract health.
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.updateHUD, object: self, userInfo: ["playerID": self.id!.hashValue, "health": self.health])
    }
    
    func playerAttack() {
        let cameraPositionInRoot = self.levelNode.convertPosition(ownCameraNode().presentationNode.position, fromNode: ownCameraNode())
        
        let cameraFacingRootCoordinates = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: ownCameraNode())
        
        let cameraFacingDirectionVector = SCNVector3Make(cameraFacingRootCoordinates.x-cameraPositionInRoot.x, (cameraFacingRootCoordinates.y-cameraPositionInRoot.y)*2, cameraFacingRootCoordinates.z-cameraPositionInRoot.z)
        
        shootingDirectionVector = VectorMath.getNormalizedVector(cameraFacingDirectionVector)
        
        fired = true
    }
    
    func jump() {
        self.physicsBody?.applyForce(SCNVector3Make(0, self.jumpHeight, 0), impulse: true)
    }
    
    func forwardMovementDirectionVector() -> SCNVector3 {
        // converts player's forward facing coordinate system into that of the sceneView rootNode
        let forwardFacingSceneCoordinates = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: self)
        
        // Get the forward movement direction vector
        let forwardMovementDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: forwardFacingSceneCoordinates)
        
        return forwardMovementDirection
    }
    
    func reloadWeapon() {
        self.equippedWeapon?.reload()
    }
    
    func ownCameraNode() -> Camera {
        return self.childNodeWithName("camera", recursively: false) as! Camera
    }
    
}
