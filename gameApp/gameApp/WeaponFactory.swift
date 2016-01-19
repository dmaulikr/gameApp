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
        handgun.ammoLoadedMax = 8
        handgun.attackInterval = 0.2
        handgun.reloadTime = 1.36
        handgun.bulletAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/gunshot.mp3")!
        handgun.bulletAudioSource?.load()
        handgun.outOfAmmoAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/outOfAmmo.wav")
        handgun.outOfAmmoAudioSource?.load()
        
        // Get model
        let weaponScene = SCNScene(named: "art.scnassets/Handgun/Handgun.dae")
        let nodeArray = weaponScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            handgun.addChildNode(childNode)
        }
        
        // Set position
        handgun.position = SCNVector3Make(1, -3, -3)
        
        // Set physics
        //let shape = SCNPhysicsShape(node: handgun, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron, SCNPhysicsShapeKeepAsCompoundKey: false]);
        //let geometry = SCNBox(width: 6, height: 6, length: 10, chamferRadius: 1)
        //let shape = SCNPhysicsShape(geometry: geometry, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeBoundingBox])
        
        handgun.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: nil)
        handgun.physicsBody?.categoryBitMask = ColliderType.Weapon
        handgun.physicsBody?.collisionBitMask = ColliderType.Wall | ColliderType.Enemy | ColliderType.Player
        
        return handgun
    }
}
