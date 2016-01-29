//
//  InventoryItemFactory.swift
//  gameApp
//
//  Created by Liza on 1/21/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import SceneKit
class InventoryItemFactory: NSObject {

    static func createWaterBottle(position: SCNVector3) -> InventoryItem
    {
        let waterBottle = InventoryItem()
        waterBottle.boostType = InventoryItem.BoostType.Health
        waterBottle.boostAmount = 10
        
        waterBottle.position = position
        
        // Get Model
        let waterBottleScene = SCNScene(named: "art.scnassets/MISC/Water_Bottle/Water_Bottle.dae")
        let nodeArray = waterBottleScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            childNode.scale = SCNVector3Make(13, 13, 13)
            childNode.rotation = SCNVector4Make(-1, 0, 0, CGFloat(M_PI_2))
            waterBottle.addChildNode(childNode)
        }
        
        waterBottle.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: nil)
        waterBottle.physicsBody?.categoryBitMask = ColliderType.InventoryItem
        waterBottle.physicsBody?.contactTestBitMask =  ColliderType.Player
        
        return waterBottle
    }
    
    static func createBoletus(position: SCNVector3) -> InventoryItem
    {
        let boletus = InventoryItem()
        boletus.boostType = InventoryItem.BoostType.Health
        boletus.boostAmount = 20
        
        boletus.position = position
        
        // Get Model
        let boletusScene = SCNScene(named: "art.scnassets/MISC/Boletus/boletus.dae")
        let nodeArray = boletusScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            childNode.scale = SCNVector3Make(100, 100, 100)
            boletus.addChildNode(childNode)
        }
        
        boletus.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        boletus.physicsBody?.categoryBitMask = ColliderType.InventoryItem
        boletus.physicsBody?.contactTestBitMask =  ColliderType.Player
        
        return boletus

    }
    
    static func createAmmoBox(position: SCNVector3) -> InventoryItem
    {
        let ammoBox = InventoryItem()
        ammoBox.boostType = InventoryItem.BoostType.Ammo
        ammoBox.boostAmount = 16
        
        ammoBox.position = position
        
        // Get Model
        let ammoBoxScene = SCNScene(named: "art.scnassets/MISC/Mr_Handy_Box/Mr_Handy_Box.dae")
        let nodeArray = ammoBoxScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            childNode.rotation = SCNVector4Make(-1, 0, 0, CGFloat(M_PI_2))
            ammoBox.addChildNode(childNode)
        }
        
        ammoBox.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: nil)
        ammoBox.physicsBody?.categoryBitMask = ColliderType.InventoryItem
        ammoBox.physicsBody?.contactTestBitMask =  ColliderType.Player
        ammoBox.physicsBody?.collisionBitMask =  ColliderType.Ground
        
        return ammoBox
        
    }
}
