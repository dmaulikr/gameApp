//
//  WeaponFactory.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

enum WeaponType {
    case Handgun
}

class WeaponFactory: NSObject {
    
    static func createHandgun() -> Weapon {
        let handgun = Weapon()
        handgun.type = WeaponType.Handgun
        handgun.baseDamage = 15
        handgun.ammoCarried = 36
        handgun.ammoLoaded = 8
        handgun.attackInterval = 0.2
        handgun.reloadTime = 1.36
        
        // Get model
        let weaponScene = SCNScene(named: "art.scnassets/Handgun/Handgun.dae")
        let nodeArray = weaponScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            // Set position
            handgun.position = SCNVector3Make(1, -3, -3)
            let geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 1)
            let shape = SCNPhysicsShape(geometry: geometry, options: nil)
            
            // Set physics
            handgun.physicsBody = SCNPhysicsBody(type: .Static, shape: shape)
            handgun.physicsBody?.categoryBitMask = ColliderType.Weapon
            handgun.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Enemy | ColliderType.Wall
            
            // Add model as child node
            handgun.addChildNode(childNode)
        }
        
        return handgun
    }
}
