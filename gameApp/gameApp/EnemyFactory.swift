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
    
    static func createCombatAndroid(position: SCNVector3) -> Enemy {
        let android = Enemy()
        android.health = 100
        android.damage = 20
        
        // Get model
        let weaponScene = SCNScene(named: "art.scnassets/Combat_Android/Combat_Android.dae")
        let nodeArray = weaponScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Set position
            android.position = position
            let geometry = SCNBox(width: 10, height: 12, length: 5, chamferRadius: 0)
            let shape = SCNPhysicsShape(geometry: geometry, options: nil)
            
            // Set physics
            android.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: shape)
            
            // Add model as child node
            android.addChildNode(childNode)
        }
        
        return android
    }
}
