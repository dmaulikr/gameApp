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
    var playerDict = NSMutableDictionary()
    var enemyDict = NSMutableDictionary()
    var enemy2: Enemy!
    var ground: SCNNode!
    var light: SCNNode!
    var levelNode: SCNNode!
    var soundtrackAudioSource: SCNAudioSource!
    
    var movementDirectionVector: SCNVector3?
    var shootingDirectionVector: SCNVector3?
    
    override init() {
        super.init()
        
    }
    
    func createLevel(parentScene: SCNScene) -> SCNNode {
        
        //parentScene.background.contents = "art.scnassets/skybox01_cube.png"
        
        levelNode = SCNNode()
        
        let levelScene = SCNScene(named: "art.scnassets/level.scn")
        let nodeArray = levelScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Add model as child node
            if childNode.name == "floor" {
                let floorGeometry = SCNFloor()
                let shape = SCNPhysicsShape(geometry: floorGeometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConvexHull])
                childNode.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
                childNode.physicsBody?.categoryBitMask = ColliderType.Ground
                childNode.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Enemy
            }
            
            if childNode.name == "wall" {
                let wallGeometry = SCNBox(width: 100, height: 60, length: 15, chamferRadius: 1)
                let shape = SCNPhysicsShape(geometry: wallGeometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConvexHull])
                childNode.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: shape)
                childNode.physicsBody?.categoryBitMask = ColliderType.Wall
                childNode.physicsBody?.collisionBitMask = ColliderType.Weapon | ColliderType.Player | ColliderType.Enemy | ColliderType.PlayerBullet
            }
            levelNode.addChildNode(childNode)
        }
        
        // Setup Player 1
        let player1 = Player(playerId: Player.ID.ID1, levelNode: levelNode)
        player1.position = SCNVector3Make(0, 0, 0)
        playerDict.setObject(player1, forKey: (player1.id?.hashValue)!)
        
        // Set player to corresponding Peer
        let peer1 = ConnectedPeers.dict.objectForKey(ConnectedPeers.firstConnectionPeerID!) as! Peer
        peer1.player = player1
        
        let player1Camera = Camera()
        player1Camera.name = "camera"
        player1Camera.position = SCNVector3(x: 0, y: player1.height, z: player1.length/2)
        //player1Camera.camera?.zFar = 2500
        player1.addChildNode(player1Camera)
        
        let player1Weapon = WeaponFactory.createHandgun()
        player1.ownCameraNode().addChildNode(player1Weapon)
        player1.equippedWeapon = player1Weapon
        player1Weapon.owner = player1
        
        
        // Setup Player 2
        let player2 = Player(playerId: Player.ID.ID2, levelNode: levelNode)
        player2.position = SCNVector3Make(50, 0, 30)
        levelNode.addChildNode(player2)
        let peer2 = ConnectedPeers.dict.objectForKey(ConnectedPeers.secondConnectionPeerID!) as! Peer
        peer2.player = player2
        playerDict.setObject(player2, forKey: (player2.id?.hashValue)!)
        
        // create and add Player 2 camera to the scene
        let player2Camera = Camera()
        player2Camera.name = "camera"
        player2Camera.position = SCNVector3(x: 0, y: player2.height, z: player2.length/2)
        player2Camera.camera?.zFar = 2500
        player2.addChildNode(player2Camera)
        
        // create Player 2 weapon
        let player2Weapon = WeaponFactory.createHandgun()
        player2Camera.addChildNode(player2Weapon)
        player2.equippedWeapon = player2Weapon
        player2Weapon.owner = player2
        
        // Setup Enemy
        enemy2 = EnemyFactory.createRobbieRabit(SCNVector3Make(-25, 0, -40), targets: [player1, player2], levelNode: levelNode)
        levelNode.addChildNode(enemy2)
        
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.castsShadow = true
        spotLight.zFar = 10
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 15, z: 5)
        let constraint = SCNLookAtConstraint(target: player1Weapon)
        light.constraints = [constraint]
        player1Camera.addChildNode(light)
        
        levelNode.addChildNode(player1)
        levelNode.addChildNode(player2)
        
        soundtrackAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/Tension Loop.wav")!
        soundtrackAudioSource.load()
        soundtrackAudioSource.loops = true
        let soundtrackAction = SCNAction.playAudioSource(soundtrackAudioSource, waitForCompletion: true)
        //levelNode.runAction(soundtrackAction)
        
        return levelNode
    }
    
    func playerAttack(playerID: Player.ID) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).playerAttack()
    }
    
    func calculatePlayerMovementTransform(playerID: Player.ID, panx: CGFloat, pany: CGFloat) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).calculateMovementTransform(panx, pany: pany)
    }
    
    func calculateCameraRotationTransform(playerID: Player.ID, panx: CGFloat, pany: CGFloat) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).calculateRotationTransform(panx, pany: pany)
    }
    
    func updateCrosshairAim(){
        (playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).updateCrosshairAim()
        (playerDict.objectForKey(Player.ID.ID2.hashValue) as! Player).updateCrosshairAim()
    }
    
    func subtractEnemyHealth() {
        if enemy2.dead == false {
            enemy2.health = enemy2.health - ((playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).equippedWeapon!.baseDamage!+((playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).damage))
            if enemy2.health <= 0 {
                enemy2.dead = true
            }
        }
    }
    
    func updateEnemy() {
        enemy2.update()
    }
    
    func updatePlayersTransform() {
        (playerDict.objectForKey(Player.ID.ID1.hashValue) as! Player).updatePlayerTransform()
        (playerDict.objectForKey(Player.ID.ID2.hashValue) as! Player).updatePlayerTransform()
    }
    
    func subtractPlayerHealth(playerID: Player.ID, damage: CGFloat) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).subtractPlayerHealth(damage)
    }
    
    func jump(playerID: Player.ID) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).jump()
    }
    
    func playerReloadWeapon(playerID: Player.ID) {
        (playerDict.objectForKey(playerID.hashValue) as! Player).reloadWeapon()
    }
}
