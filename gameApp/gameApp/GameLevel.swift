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
    var player: Player!
    var enemy: Enemy!
    var camera: Camera!
    var weapon: Weapon!
    var ground: SCNNode!
    var light: SCNNode!
    var bullet: SCNNode?
    var bulletArray: Array<SCNNode>!
    var levelNode: SCNNode!
    var bulletAudioSource: SCNAudioSource!
    
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
    
    func createLevel(parentScene: SCNScene) -> SCNNode {
        
        parentScene.background.contents = "art.scnassets/skybox01_cube.png"
        
        levelNode = SCNNode()
        
//        let islandScene = SCNScene(named: "art.scnassets/Small Tropical Island/Untitled.dae")
//        let nodeArray = islandScene!.rootNode.childNodes
//        
//        let islandNode = SCNNode()
//        islandNode.position = SCNVector3Make(0, 0, -450)
//        
//        for childNode in nodeArray {
//            
//            // Add model as child node
//            islandNode.addChildNode(childNode)
//        }
//        let shape = SCNPhysicsShape(node: islandNode, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron, SCNPhysicsShapeKeepAsCompoundKey: false]);
//        islandNode.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
//        islandNode.physicsBody?.categoryBitMask = ColliderType.Ground
//        islandNode.physicsBody?.collisionBitMask = ColliderType.Bullet | ColliderType.Enemy | ColliderType.Player
//        levelNode.addChildNode(islandNode)
        
        let levelScene = SCNScene(named: "art.scnassets/level.scn")
        let nodeArray = levelScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Add model as child node
            //childNode.physicsBody?.categoryBitMask = ColliderType.Ground
            //childNode.physicsBody?.collisionBitMask = ColliderType.Enemy | ColliderType.Player
            levelNode.addChildNode(childNode)
        }
        
        // create ground
//        let groundGeometry = SCNFloor()
//        groundGeometry.reflectivity = 0
//        groundGeometry.firstMaterial!.diffuse.contents = "art.scnassets/Grass_1.png"
//        //groundGeometry.firstMaterial!.locksAmbientWithDiffuse = true
//        groundGeometry.firstMaterial!.shininess = 0.2
//        ground = SCNNode(geometry: groundGeometry)
//        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
//        ground.physicsBody = SCNPhysicsBody(type: .Static, shape: groundShape)
//        ground.physicsBody?.categoryBitMask = ColliderType.Ground
//        ground.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Enemy
//        levelNode.addChildNode(ground)
        
        // create character
        player = Player()
        player.position = SCNVector3Make(0, 0, 0)
        levelNode.addChildNode(player)
        
        // create and add a camera to the scene
        self.camera = Camera()
        self.camera.position = SCNVector3(x: 0, y: player.height, z: player.length/2) // over-the-shoulder view
        player.addChildNode(self.camera)
        
        // create weapon
        weapon = WeaponFactory.createHandgun()
        camera.addChildNode(weapon)
        player.equippedWeapon = weapon
        
        // create enemy
        enemy = EnemyFactory.createCombatAndroid(SCNVector3Make(-25, 0, -40), target: player, levelNode: levelNode)
        levelNode.addChildNode(enemy)
        
        // add lighting
        let ambientLight = SCNLight()
        ambientLight.color = NSColor.lightGrayColor()
        ambientLight.type = SCNLightTypeAmbient
        self.camera.light = ambientLight  // Add ambient lighting to the camera
        //levelNode.addChildNode(self.camera.light)
        
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.castsShadow = true
        spotLight.zFar = 30
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        let constraint = SCNLookAtConstraint(target: player)
        light.constraints = [constraint]
        
        movementDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        shootingDirectionVector = SCNVector3(x: 0, y: 0, z: 0)
        bulletStart = SCNVector3Make(0, 0, 0)
        
        horizontalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldHorizontalRotation = player.transform
        oldVerticalRotation = self.camera.transform
        
        fired = false
        bulletArray = [SCNNode]()
        bulletAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/gunshot.mp3")!
        
        return levelNode
    }
    
    func playerAttack() {
        let cameraPositionInRoot = self.levelNode.convertPosition(self.camera.presentationNode.position, fromNode: self.player)
        
        let cameraFacingRootCoordinates = self.getNodeHeadingInWorldSpace(self.camera)
        
        let cameraFacingDirectionVector = SCNVector3Make(cameraFacingRootCoordinates.x-cameraPositionInRoot.x, (cameraFacingRootCoordinates.y-cameraPositionInRoot.y)*2, cameraFacingRootCoordinates.z-cameraPositionInRoot.z)
        
        shootingDirectionVector = VectorMath.getNormalizedVector(cameraFacingDirectionVector)
        
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
        if abs(panx) > 5 || abs(pany) > 5 {
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
        // converts player's forward facing coordinate system into that of the sceneView rootNode
        let forwardFacingSceneCoordinates = self.getNodeHeadingInWorldSpace(player) 
        
        // Get the forward movement direction vector
        let forwardMovementDirection = VectorMath.getDirectionVector(player.presentationNode.position, finishPoint: forwardFacingSceneCoordinates)
        
        return forwardMovementDirection
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
    
    func updatePlayerTransform() {
        // First take care of rotation
        var playerTransform = SCNMatrix4Mult(oldHorizontalRotation!, horizontalRotation!)
        
        // Then take care of translation
        playerTransform.m41 = player.presentationNode.position.x + movementDirectionVector!.x*player.speed
        playerTransform.m42 = player.presentationNode.position.y + movementDirectionVector!.y*player.speed
        playerTransform.m43 = player.presentationNode.position.z + movementDirectionVector!.z*player.speed
        playerTransform.m44 = 1.0
        
        // Set player transform
        player.transform = playerTransform
        camera.transform = SCNMatrix4Mult(oldVerticalRotation!, verticalRotation!)
        
        oldHorizontalRotation = player.transform
        oldVerticalRotation = camera.transform
    }
    
    func updateCrosshairAim(){
        
        if fired == true {
            let bulletSoundAction = SCNAction.playAudioSource(bulletAudioSource, waitForCompletion: true)
            weapon.runAction(bulletSoundAction)
            let bulletGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
            let bulletMaterial = SCNMaterial()
            bulletMaterial.diffuse.contents = NSColor.orangeColor()
            bulletGeometry.materials = [bulletMaterial]
            bullet = SCNNode(geometry: bulletGeometry)
            bullet!.position = levelNode.convertPosition(camera.presentationNode.position, fromNode: player)
            bullet!.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
            bullet!.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
            bullet!.physicsBody?.categoryBitMask = ColliderType.Bullet
            bullet!.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Ground
            bullet!.physicsBody?.contactTestBitMask = ColliderType.Enemy | ColliderType.Player | ColliderType.Ground | ColliderType.Wall
            bullet!.name = "bullet"
            
            levelNode.addChildNode(bullet!)
            bulletArray.append(bullet!)
            
            let impulse = VectorMath.multiplyVectorByScalar(shootingDirectionVector!, right: 300)
            
            bullet!.physicsBody?.applyForce(impulse, impulse: true)
            
            fired = false
        }
    }
    
    func subtractEnemyHealth() {
        if enemy.dead == false {
        enemy.health = enemy.health - (weapon.baseDamage!+player.damage)
        print("Enemy health: \(enemy.health)")
            if enemy.health <= 0 {
                print("Enemy dead")
                enemy.dead = true
            }
        }
    }
    
    func updateEnemy() {
        enemy.update()
    }
    
    func getNodeHeadingInWorldSpace(node: SCNNode) -> SCNVector3 {
        return self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: node)
    }

    
}
