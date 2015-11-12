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
        android.physicsBody?.collisionBitMask = ColliderType.Bullet | ColliderType.Ground | ColliderType.Weapon | ColliderType.Wall
        android.physicsBody?.contactTestBitMask = ColliderType.Bullet | ColliderType.Player 
        return android
    }
}
