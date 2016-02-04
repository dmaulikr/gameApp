//
//  LevelFactory.swift
//  gameApp
//
//  Created by Liza on 2/3/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class LevelFactory: NSObject {
    
    static func createHorrorLevel(parentScene: SCNScene) -> Level {
        parentScene.background.contents = "art.scnassets/Levels/skybox01_cube.png"
        let level = Level()
        level.worldNode = SCNNode()
        level.enemyType = EnemyFactory.EnemyType.LambentMale
        
        let levelScene = SCNScene(named: "art.scnassets/Levels/level2.scn")
        let nodeArray = levelScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Add model as child node
            if childNode.name == "floor" {
                let floorGeometry = SCNFloor()
                floorGeometry.reflectivity = 0
                let shape = SCNPhysicsShape(geometry: floorGeometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConvexHull])
                childNode.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
                childNode.physicsBody?.categoryBitMask = ColliderType.Ground
                childNode.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Enemy | ColliderType.InventoryItem | ColliderType.WorldItem
                childNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Textures/SoilMud0010_1_S.jpg"
                childNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1.5, 1.5, 1.5)
                childNode.geometry?.firstMaterial?.shininess = 0
            }
            
            if childNode.name == "wall" {
                childNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Textures/ConcreteMossy0042_1_S.jpg"
            }
            
            level.worldNode.addChildNode(childNode)
        }
        
        // Setup Player 1
        let player1 = Player(playerId: Player.ID.ID1, levelNode: level.worldNode)
        player1.position = SCNVector3Make(0, 0, 0)
        level.playerDict.setObject(player1, forKey: (player1.id?.hashValue)!)
        
        // Set player to corresponding Peer
        let peer1 = ConnectedPeers.dict.objectForKey(ConnectedPeers.firstConnectionPeerID!) as! Peer
        peer1.player = player1
        
        let player1Camera = Camera()
        player1Camera.name = "camera"
        player1Camera.position = SCNVector3(x: 0, y: player1.height, z: player1.length/2)
        player1Camera.camera?.zFar = 2500
        player1.addChildNode(player1Camera)
        
        let player1Weapon = WeaponFactory.createHandgun()
        player1.ownCameraNode().addChildNode(player1Weapon)
        player1.equippedWeapon = player1Weapon
        player1Weapon.owner = player1
        
        
        // Setup Player 2
        let player2 = Player(playerId: Player.ID.ID2, levelNode: level.worldNode)
        player2.position = SCNVector3Make(50, 0, 30)
        level.worldNode.addChildNode(player2)
        let peer2 = ConnectedPeers.dict.objectForKey(ConnectedPeers.secondConnectionPeerID!) as! Peer
        peer2.player = player2
        level.playerDict.setObject(player2, forKey: (player2.id?.hashValue)!)
        
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
        
        // Setup water bottle
        let waterBottle = InventoryItemFactory.createWaterBottle(SCNVector3Make(0, 0, -100))
        level.worldNode.addChildNode(waterBottle)
        
        // Setup ammo box
        let ammoBox = InventoryItemFactory.createAmmoBox(SCNVector3Make(0, 0, 0))
        level.worldNode.addChildNode(ammoBox)
        
        level.worldNode.addChildNode(player1)
        level.worldNode.addChildNode(player2)
        
        // Create array of spawnLocations
        level.spawnLocations.append(SCNVector3Make(645, 0, 69))
        level.spawnLocations.append(SCNVector3Make(338, 0, 69))
        level.spawnLocations.append(SCNVector3Make(-264, 0, -232))
        level.spawnLocations.append(SCNVector3Make(443, 0, -232))
        level.spawnLocations.append(SCNVector3Make(9, 0, -45))
        
        level.spawnPeriod = 30.0
        
        return level
    }
    
    static func createExtremeHorrorLevel(parentScene: SCNScene) -> Level {
        let level = Level()
        level.worldNode = SCNNode()
        level.enemyType = EnemyFactory.EnemyType.RobbieRabbit
        
        let levelScene = SCNScene(named: "art.scnassets/Levels/level1.scn")
        let nodeArray = levelScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Add model as child node
            if childNode.name == "floor" {
                let floorGeometry = SCNFloor()
                floorGeometry.reflectivity = 0
                let shape = SCNPhysicsShape(geometry: floorGeometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConvexHull])
                childNode.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
                childNode.physicsBody?.categoryBitMask = ColliderType.Ground
                childNode.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Enemy | ColliderType.InventoryItem | ColliderType.WorldItem
                childNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Textures/FloorsCheckerboard0018_1_S.jpg"
            }
            
            if childNode.name == "wall" {
                childNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Textures/PlasterBareSeams0015_1_S.jpg"
            }
            
            if childNode.name == "box" {
                childNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Textures/PlasterBareSeams0031_1_S.jpg"
            }
            
            level.worldNode.addChildNode(childNode)
        }
        
        // Setup Player 1
        let player1 = Player(playerId: Player.ID.ID1, levelNode: level.worldNode)
        player1.position = SCNVector3Make(0, 0, 0)
        level.playerDict.setObject(player1, forKey: (player1.id?.hashValue)!)
        
        // Set player to corresponding Peer
        let peer1 = ConnectedPeers.dict.objectForKey(ConnectedPeers.firstConnectionPeerID!) as! Peer
        peer1.player = player1
        
        let player1Camera = Camera()
        player1Camera.name = "camera"
        player1Camera.position = SCNVector3(x: 0, y: player1.height, z: player1.length/2)
        player1Camera.camera?.zFar = 2500
        player1.addChildNode(player1Camera)
        
        let player1Weapon = WeaponFactory.createHandgun()
        player1.ownCameraNode().addChildNode(player1Weapon)
        player1.equippedWeapon = player1Weapon
        player1Weapon.owner = player1
        
        
        // Setup Player 2
        let player2 = Player(playerId: Player.ID.ID2, levelNode: level.worldNode)
        player2.position = SCNVector3Make(50, 0, 30)
        level.worldNode.addChildNode(player2)
        let peer2 = ConnectedPeers.dict.objectForKey(ConnectedPeers.secondConnectionPeerID!) as! Peer
        peer2.player = player2
        level.playerDict.setObject(player2, forKey: (player2.id?.hashValue)!)
        
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
        
        // Setup water bottle
        let waterBottle = InventoryItemFactory.createWaterBottle(SCNVector3Make(0, 0, 50))
        level.worldNode.addChildNode(waterBottle)
        
        // Setup ammo box
        let ammoBox = InventoryItemFactory.createAmmoBox(SCNVector3Make(0, 0, 0))
        level.worldNode.addChildNode(ammoBox)
        
        level.worldNode.addChildNode(player1)
        level.worldNode.addChildNode(player2)
        
        level.soundtrackAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/Tension Loop.wav")!
        level.soundtrackAudioSource!.load()
        level.soundtrackAudioSource!.loops = true
        level.soundtrackAudioSource!.volume = 0.5
        
        // Create array of spawnLocations
        level.spawnLocations.append(SCNVector3Make(-12, 0, -56))
        level.spawnLocations.append(SCNVector3Make(487, 0, -131))
        level.spawnLocations.append(SCNVector3Make(555, 0, 161))
        level.spawnLocations.append(SCNVector3Make(500, 0, 326))
        level.spawnLocations.append(SCNVector3Make(494, 0, -20))
        level.spawnLocations.append(SCNVector3Make(9, 0, -45))
        
        level.spawnPeriod = 30.0
        
        return level
    }
}
