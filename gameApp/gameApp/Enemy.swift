//
//  Enemy.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Enemy: SCNNode {
    
    var health: CGFloat?
    var damage: CGFloat?
    
    override init() {
        super.init()
        
        self.physicsBody?.categoryBitMask = ColliderType.Enemy
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Enemy | ColliderType.Bullet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
