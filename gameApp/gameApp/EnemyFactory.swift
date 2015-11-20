//
//  EnemyFactory.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class EnemyFactory: NSObject {
    
    static func createCombatAndroid(position: SCNVector3, target: Player, levelNode: SCNNode) -> Enemy {
        let android = Enemy()
        android.health = 100
        android.damage = 20
        android.speed = 0.4
        android.panicDistance = 20
        android.viewDistance = 50
        android.target = target
        android.levelNode = levelNode
        
        android.position = position
        
        // Get model
        let weaponScene = SCNScene(named: "art.scnassets/Combat_Android/Combat_Android.dae")
        let nodeArray = weaponScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Add model as child node
            childNode.physicsBody = nil;
            childNode.scale = SCNVector3Make(5, 5, 5)
            childNode.rotation = SCNVector4Make(-1, 0, 0, CGFloat(M_PI_2))
            android.addChildNode(childNode)
        }
        let shape = SCNPhysicsShape(node: android, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron, SCNPhysicsShapeKeepAsCompoundKey: false]);
        //android.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
        android.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: shape)
        android.physicsBody?.categoryBitMask = ColliderType.Enemy
        android.physicsBody?.collisionBitMask = ColliderType.PlayerBullet | ColliderType.Ground | ColliderType.Weapon | ColliderType.Wall | ColliderType.Player
        android.physicsBody?.contactTestBitMask = ColliderType.PlayerBullet | ColliderType.Player
        return android
    }
    
    static func createRobbieRabit(position: SCNVector3, target: Player, levelNode: SCNNode) -> Enemy {
        let robbie = Enemy()
        robbie.health = 100
        robbie.damage = 20
        robbie.speed = 0.4
        robbie.panicDistance = 20
        robbie.viewDistance = 50
        robbie.target = target
        robbie.levelNode = levelNode
        
        // Get model
        let robbieScene = SCNScene(named: "art.scnassets/Robbie_the_Rabbit_rigged copy.scn")
        let nodeArray = robbieScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            robbie.addChildNode(childNode)
        }
        
        // Set textures"
        robbie.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_d.tga"
        robbie.geometry?.firstMaterial?.specular.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_s.tga"
        robbie.geometry?.firstMaterial?.normal.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_n.tga"
        
        //let shape = SCNPhysicsShape(node: robbie, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron, SCNPhysicsShapeKeepAsCompoundKey: false]);
        robbie.position = position
        robbie.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        robbie.physicsBody?.categoryBitMask = ColliderType.Enemy
        robbie.physicsBody?.collisionBitMask =  ColliderType.Ground | ColliderType.Wall | ColliderType.Player | ColliderType.Weapon
        robbie.physicsBody?.contactTestBitMask = ColliderType.PlayerBullet
        robbie.physicsBody?.contactTestBitMask = ColliderType.Player | ColliderType.Weapon
        robbie.physicsBody?.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0)
        
        return robbie
    }
}
