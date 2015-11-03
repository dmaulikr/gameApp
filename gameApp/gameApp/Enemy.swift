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
    
    var health: CGFloat!
    var damage: CGFloat!
    var speed: CGFloat!
    var viewDistance: CGFloat!
    var stateMachine: AIStateMachine<Enemy>?
    var steer: SteeringBehaviors!
    var steeringForce: SCNVector3?
    var target: Player!
    var levelNode: SCNNode!
    
    override init() {
        super.init()
        
        stateMachine = AIStateMachine(owner: self)
        steer = SteeringBehaviors(owner: self)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update() {
        self.position = VectorMath.addVectorToVector(self.position, right: self.steer.seek(target.presentationNode.position))
        //self.rotation =
    }
    
}
