//
//  Player.swift
//  gameApp
//
//  Created by Liza Girsova on 10/11/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Player: SCNNode {
    
    let width: CGFloat = 5
    let height: CGFloat = 12
    let length: CGFloat = 2
    let speed: CGFloat = 0.3
    let jumpHeight: CGFloat = 6
    
    override init() {
        // Initialize player
        super.init()
        let geometry = SCNBox(width: self.width, height: self.height, length: self.length, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.blueColor()
        geometry.materials = [material]
        self.geometry = geometry
        
        // Set player physics
        let bodyShape = SCNPhysicsShape(geometry: geometry, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: bodyShape)
        self.physicsBody?.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0)
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Bot1 | ColliderType.Bot2 | ColliderType.Ground
        self.physicsBody?.friction = 0.7
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
