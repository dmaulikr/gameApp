//
//  GameLevel.swift
//  gameApp
//
//  Created by Liza Girsova on 10/28/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class GameLevel: NSObject {
    var sprite: Player!
    var enemy: Enemy!
    var camera: Camera!
    var weapon: Weapon!
    var ground: SCNNode!
    var light: SCNNode!
    var bullet: SCNNode?
    var levelNode: SCNNode!
    
    var movementDirectionVector: SCNVector3?
    var shootingDirectionVector: SCNVector3?
    var bulletStart: SCNVector3?
    
    var oldHorizontalRotation: SCNMatrix4?
    var oldVerticalRotation: SCNMatrix4?
    
    var horizontalRotation: SCNMatrix4?
    var verticalRotation: SCNMatrix4?
    
    var fired: Bool?
    
    override init() {
        super.init()
        
    }
    
    func createLevel() -> SCNNode {
        
        levelNode = SCNNode()
        
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
        levelNode.addChildNode(islandNode)
        
        
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
        levelNode.addChildNode(enemy)
        
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
        
        levelNode.addChildNode(light)
        levelNode.addChildNode(ground)
        levelNode.addChildNode(sprite)
        
        movementDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        shootingDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        bulletStart = SCNVector3Make(0, 0, 0)
        
        horizontalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldHorizontalRotation = sprite.transform
        oldVerticalRotation = self.camera.transform
        
        fired = false
        
        return levelNode
    }
    
    func playerJump() {
        self.sprite.physicsBody?.applyForce(SCNVector3Make(0, sprite.jumpHeight, 0), impulse: true)
    }
    
    func playerAttack() {
        let cameraPositionInRoot = self.levelNode.convertPosition(self.camera.presentationNode.position, fromNode: self.sprite)
        
        let cameraFacingRootCoordinates = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: self.camera)
        
        let cameraFacingDirectionVector = SCNVector3Make(cameraFacingRootCoordinates.x-cameraPositionInRoot.x, (cameraFacingRootCoordinates.y-cameraPositionInRoot.y)*2, cameraFacingRootCoordinates.z-cameraPositionInRoot.z)
        
        shootingDirectionVector = getNormalizedVector(cameraFacingDirectionVector)
        
        fired = true

    }
    
    func calculatePlayerMovementTransform(panx: CGFloat, pany: CGFloat) {
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
        if abs(panx) > 15 || abs(pany) > 15 {
            self.setMovementDirection(self.forwardMovementDirectionVector(), panx: panx, pany: pany)
        } else {
            // pan gesture not significant
            movementDirectionVector = SCNVector3Make(0, 0, 0)
        }
    }
    
    func calculateCameraRotationTransform(panx: CGFloat, pany: CGFloat) {
        // First generate a vector from the translation points
        let panVector = CGVectorMake(panx, pany)
        
        // Normalize vector to make sure the speed of rotation stays constant
        let vectorMagnitude = sqrtf(Float(panVector.dx*panVector.dx)+Float(panVector.dy*panVector.dy))
        let normalizedVector = CGVectorMake(panVector.dx/CGFloat(vectorMagnitude), panVector.dy/CGFloat(vectorMagnitude))
        
        // Generate angles based on the normalized vector
        let horizontalAngle = acos(normalizedVector.dx / 70) - CGFloat(M_PI_2)
        let verticalAngle = acos(normalizedVector.dy / 70) - CGFloat(M_PI_2)
        
        // Create a matrix that represents the horizontal rotation
        self.horizontalRotation = SCNMatrix4MakeRotation(CGFloat(horizontalAngle), 0, 1, 0)
        
        
        // First check if camera rotation is valid
        if self.cameraRotationValid(CGFloat(verticalAngle)) == true {
            self.verticalRotation = SCNMatrix4MakeRotation(CGFloat(verticalAngle), 1, 0, 0)
        } else {
            self.verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        }
    }
    
    func playerNotMoving() {
        movementDirectionVector = SCNVector3Make(0, 0, 0)
    }
    
    func cameraNotRotating() {
        self.horizontalRotation = SCNMatrix4Identity
        self.verticalRotation = SCNMatrix4Identity
    }
    
    func forwardMovementDirectionVector() -> SCNVector3 {
        // converts sprite's forward facing coordinate system into that of the sceneView rootNode
        let forwardFacingSceneCoordinates = levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: sprite)
        
        // Get the forward movement direction vector
        let forwardMovementDirection = SCNVector3(x: forwardFacingSceneCoordinates.x - sprite.presentationNode.position.x, y: forwardFacingSceneCoordinates.y - sprite.presentationNode.position.y, z: forwardFacingSceneCoordinates.z - sprite.presentationNode.position.z)
        
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
            bullet!.position = levelNode.convertPosition(camera.presentationNode.position, fromNode: sprite)
            bullet!.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
            bullet!.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
            bullet!.physicsBody?.categoryBitMask = ColliderType.Bullet
            bullet!.physicsBody?.collisionBitMask = ColliderType.Enemy | ColliderType.Player | ColliderType.Ground
            levelNode.addChildNode(bullet!)
            
            let impulse = SCNVector3Make(shootingDirectionVector!.x*300, shootingDirectionVector!.y*300, shootingDirectionVector!.z*300)
            
            bullet!.physicsBody?.applyForce(impulse, impulse: true)
            
            fired = false
        }
    }

    
}
