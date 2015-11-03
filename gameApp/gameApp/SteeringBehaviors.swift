//
//  SteeringBehaviors.swift
//  gameApp
//
//  Created by Liza Girsova on 11/2/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

struct Behavior {
    static let None = 0x1 << 0
    static let Seek = 0x1 << 1
    static let Flee = 0x1 << 2
    static let Arrive = 0x1 << 3
    static let Wander = 0x1 << 4
    static let WallAvoidance = 0x1 << 5
    static let Pursuit = 0x1 << 6
    static let Evade = 0x1 << 7
    static let Hide = 0x1 << 8
}

class SteeringBehaviors: NSObject {
    
    
    var owner: Enemy!
    var bitBehaviors: Int!
    
    init(owner: Enemy) {
        super.init()
        self.owner = owner
    }
    
    func on(behaviorType: Int) -> Bool {
        return (bitBehaviors & behaviorType) == behaviorType
    }
    
    func seek(targetPos: SCNVector3) -> SCNVector3 {
        
        let movementDirection: SCNVector3 = VectorMath.getDirectionVector(owner.presentationNode.position, finishPoint: targetPos)
        
        let movementDirectionNormalized = VectorMath.getNormalizedVector(movementDirection)
        
        let seekVector = VectorMath.multiplyVectorByScalar(movementDirectionNormalized, right: owner.speed)
        
        // Get the direction the current owner is facing
        let ownerFacingDirection = owner.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: owner)
        
        // Get the angle between the current owner's rotation vector and the movementDirection
        let angle = acos(VectorMath.dotProduct(movementDirectionNormalized, right: ownerFacingDirection))
        
        let rotation = SCNVector4Make(0, 1, 0, angle)
        
        let movementAndRotation:(SCNVector3, SCNVector4) = (seekVector, rotation)
        
        return seekVector
    }
    
    func seekOn() {
        bitBehaviors = bitBehaviors | Behavior.Seek
    }
    
    func seekOff() {
        if on(Behavior.Seek) {
            bitBehaviors = bitBehaviors ^ Behavior.Seek
        }
    }
    
    func isSeekOn() -> Bool {
        return on(Behavior.Seek)
    }
}
