//
//  WorldItemFactory.swift
//  gameApp
//
//  Created by Liza on 1/21/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class WorldItemFactory: NSObject {

    static func createSedan(position: SCNVector3) -> SCNNode
    {
        let worldItem = SCNNode()
        worldItem.position = position
        
        // Get Model
        let worldItemScene = SCNScene(named: "art.scnassets/MISC/Sedan/Chryslus_Corvega_Sedan_Post_Nuclear_Edition.dae")
        let nodeArray = worldItemScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            childNode.scale = SCNVector3Make(6, 6, 6)
            childNode.rotation = SCNVector4Make(-1, 0, 0, CGFloat(M_PI))
            worldItem.addChildNode(childNode)
        }
        
        worldItem.physicsBody = SCNPhysicsBody(type: .Kinematic, shape: nil)
        worldItem.physicsBody?.categoryBitMask = ColliderType.WorldItem
        worldItem.physicsBody?.collisionBitMask =  ColliderType.Player | ColliderType.Weapon
        
        return worldItem
    }
}
