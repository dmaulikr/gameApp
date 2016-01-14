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

enum Deceleration: Int {
    case Slow = 3
    case Normal = 2
    case Fast = 1
}

class SteeringBehaviors: NSObject {
    
    
    var owner: Enemy!
    var bitBehaviors: Int!
    var steering: SCNVector3!
    
    init(owner: Enemy) {
        super.init()
        self.owner = owner
        self.steering = SCNVector3Make(0, 0, 0)
    }
    
    func resetSteering() {
        steering = SCNVector3Make(0, 0, 0)
    }
    
    func on(behaviorType: Int) -> Bool {
        return (bitBehaviors & behaviorType) == behaviorType
    }
    
    func seek(targetPos: SCNVector3) -> SCNVector3 {
        
        let movementDirection: SCNVector3 = VectorMath.getDirectionVector(owner.presentationNode.position, finishPoint: targetPos)
        
        let movementDirectionNormalized = VectorMath.getNormalizedVector(movementDirection)
        
        let seekVector = VectorMath.multiplyVectorByScalar(movementDirectionNormalized, right: owner.speed)
        
        //steering = VectorMath.addVectorToVector(steering, right: seekVector)
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
    
    func arrive(targetPos: SCNVector3) -> SCNVector3 {
        
        let movementDirection: SCNVector3 = VectorMath.getDirectionVector(owner.presentationNode.position, finishPoint: targetPos)
        
        // Calculate distance to target position
        let distance = VectorMath.getVectorMagnitude(movementDirection)
        
        let deceleration: Deceleration
        
        if distance > 50 {
            deceleration = Deceleration.Fast
        } else if distance > 30 {
            deceleration = Deceleration.Normal
        } else {
            deceleration = Deceleration.Slow
        }
        
        if distance > 25 {
            let decelerationTweaker: CGFloat = 60
            
            // calculate the speed required to reach the target given the desired deceleration
            var speed = distance / (CGFloat(deceleration.rawValue) * decelerationTweaker)
            
            // Make sure the velocity does not exceed the max
            speed = min(speed, owner.speed)
            
            let targetVector = VectorMath.multiplyVectorByScalar(movementDirection, right: CGFloat(speed / distance))
            
            steering = VectorMath.addVectorToVector(steering, right: targetVector)
            return targetVector
        }
        //steering = VectorMath.addVectorToVector(steering, right: SCNVector3Make(0, 0, 0))
        return SCNVector3Make(0, 0, 0)
    }
    
    func arriveOn() {
        bitBehaviors = bitBehaviors | Behavior.Arrive
    }
    
    func arriveOff() {
        if on(Behavior.Arrive) {
            bitBehaviors = bitBehaviors ^ Behavior.Arrive
        }
    }
    
    func isArriveOn() -> Bool {
        return on(Behavior.Arrive)
    }
    
    func flee(targetPos: SCNVector3) -> SCNVector3 {
        let movementDirection: SCNVector3 = VectorMath.getDirectionVector(targetPos, finishPoint: owner.presentationNode.position)
        
        let movementDirectionNormalized = VectorMath.getNormalizedVector(movementDirection)
        
        let fleeVector = VectorMath.multiplyVectorByScalar(movementDirectionNormalized, right: owner.speed)
        
        //steering = VectorMath.addVectorToVector(steering, right: fleeVector)
        return fleeVector
    }
    
    func fleeOn() {
        bitBehaviors = bitBehaviors | Behavior.Flee
    }
    
    func fleeOff() {
        if on(Behavior.Flee) {
            bitBehaviors = bitBehaviors ^ Behavior.Flee
        }
    }
    
    func isFleeOn() -> Bool {
        return on(Behavior.Arrive)
    }
    
    func pursuit(evader: Player) -> SCNVector3 {
        
        let toEvader = VectorMath.getDirectionVector(owner.presentationNode.position, finishPoint: evader.presentationNode.position)
        
        let lookAheadTime = VectorMath.getVectorMagnitude(toEvader) / (owner.speed + evader.speed)
        
        let forwardFacingOwnerV3 = owner.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: owner.presentationNode)
        
        let predictedVector = VectorMath.addVectorToVector(evader.presentationNode.position, right: VectorMath.multiplyVectorByScalar(forwardFacingOwnerV3, right: lookAheadTime))

        // seek to the predicted future position of evader
        //steering = VectorMath.addVectorToVector(steering, right: self.seek(predictedVector))
        
        return self.seek(predictedVector)
    }
    
    func pursuitOn() {
        bitBehaviors = bitBehaviors | Behavior.Pursuit
    }
    
    func pursuitOff() {
        if on(Behavior.Pursuit) {
            bitBehaviors = bitBehaviors ^ Behavior.Pursuit
        }
    }
    
    func isPursuitOn() -> Bool {
        return on(Behavior.Pursuit)
    }
    
    func wander() -> SCNVector3 {
        
        // radius of the constraining circle
        let circleRadius: CGFloat = 1
        
        // distance the wander circle is projected in front of the agent
        let circleDistance: CGFloat = 1
        
        // the maximum amount of random displacement that can be added to target each second
        let wanderJitter: Float = Float(M_PI)
        
        let randXValue = Int(arc4random_uniform(3))-1

        let randomStartGlobal = owner.levelNode.convertPosition(SCNVector3Make(CGFloat(randXValue), 0, 1), fromNode: owner.presentationNode)
        
        // Create a directionVector
        let forwardDirection = VectorMath.getDirectionVector(owner.presentationNode.position, finishPoint: randomStartGlobal)

        // First calculate the circle's position
        // It is always in front of the owner
        let circleCenter: SCNVector3 = VectorMath.multiplyVectorByScalar(forwardDirection, right: circleDistance)
        
        // Next calculate the displacement force, which is responsible for right or left turn
        // Since it just generates disturbance, it can point anywhere
        let displacement = VectorMath.multiplyVectorByScalar(forwardDirection, right: circleRadius)

        // Randomly calculate turn direction
        let randTurnValue = Float(arc4random_uniform(2)+1)
        var turn: Float
        
        if randTurnValue == 1 {
            turn = 1
        } else {
            turn = -1
        }
        
        // Generate random vector direction based on angle
        let rotAngle = Float(arc4random_uniform(UInt32.max))/Float(UInt32.max) * wanderJitter
        
        let rotationMatrix = SCNMatrix4MakeRotation(CGFloat(rotAngle), 0, CGFloat(turn), 0)
        let glkVector = GLKVector3Make(Float(displacement.x), Float(displacement.y), Float(displacement.z))
        let glkMatrix = GLKMatrix4Make(Float(rotationMatrix.m11), Float(rotationMatrix.m12), Float(rotationMatrix.m13), Float(rotationMatrix.m14), Float(rotationMatrix.m21), Float(rotationMatrix.m22), Float(rotationMatrix.m23), Float(rotationMatrix.m24), Float(rotationMatrix.m31), Float(rotationMatrix.m32), Float(rotationMatrix.m33), Float(rotationMatrix.m34), Float(rotationMatrix.m41), Float(rotationMatrix.m42), Float(rotationMatrix.m43), Float(rotationMatrix.m44))
        let glkRotatedVector = GLKMatrix4MultiplyVector3WithTranslation(glkMatrix, glkVector)
        var rotatedVector = SCNVector3FromGLKVector3(glkRotatedVector)
        rotatedVector.y = 0
        
        var wanderForce = VectorMath.addVectorToVector(circleCenter, right: rotatedVector)
        
        // Make the wander force less strong so enemy walks slower
        wanderForce = VectorMath.multiplyVectorByScalar(wanderForce, right: 0.7)
        
        steering = VectorMath.addVectorToVector(steering, right: wanderForce)
        
        //return wanderForceDirection
        return wanderForce
    }
    
    func wanderOn() {
        bitBehaviors = bitBehaviors | Behavior.Wander
    }
    
    func wanderOff() {
        if on(Behavior.Wander) {
            bitBehaviors = bitBehaviors ^ Behavior.Wander
        }
    }
    
    func isWanderOn() -> Bool {
        return on(Behavior.Wander)
    }

    func wallAvoidance() -> SCNVector3 {
        // a vector that has the same direction as the owner's movement direction but is longer
        // this represents the owner's line of sight
        // Forward Direction Vector
        let ownerDirection = VectorMath.getNormalizedVector((owner.physicsBody?.velocity)!)
        let seeAhead = VectorMath.multiplyVectorByScalar(ownerDirection, right: 50)
        let seeAheadPoint = VectorMath.addVectorToVector(owner.presentationNode.position, right: seeAhead)
        
        // Left Feeler
        let rotationMatrix = SCNMatrix4MakeRotation(CGFloat(M_PI_4), 0, -1, 0)
        let glkVector = GLKVector3Make(Float(seeAhead.x), Float(seeAhead.y), Float(seeAhead.z))
        let glkMatrix = GLKMatrix4Make(Float(rotationMatrix.m11), Float(rotationMatrix.m12), Float(rotationMatrix.m13), Float(rotationMatrix.m14), Float(rotationMatrix.m21), Float(rotationMatrix.m22), Float(rotationMatrix.m23), Float(rotationMatrix.m24), Float(rotationMatrix.m31), Float(rotationMatrix.m32), Float(rotationMatrix.m33), Float(rotationMatrix.m34), Float(rotationMatrix.m41), Float(rotationMatrix.m42), Float(rotationMatrix.m43), Float(rotationMatrix.m44))
        let glkRotatedVector = GLKMatrix4MultiplyVector3WithTranslation(glkMatrix, glkVector)
        var leftFeeler = SCNVector3FromGLKVector3(glkRotatedVector)
        
        // Right Feeler
        let rotationMatrix2 = SCNMatrix4MakeRotation(CGFloat(M_PI_4), 0, 1, 0)
        let glkVector2 = GLKVector3Make(Float(seeAhead.x), Float(seeAhead.y), Float(seeAhead.z))
        let glkMatrix2 = GLKMatrix4Make(Float(rotationMatrix2.m11), Float(rotationMatrix2.m12), Float(rotationMatrix2.m13), Float(rotationMatrix2.m14), Float(rotationMatrix2.m21), Float(rotationMatrix2.m22), Float(rotationMatrix2.m23), Float(rotationMatrix2.m24), Float(rotationMatrix2.m31), Float(rotationMatrix2.m32), Float(rotationMatrix2.m33), Float(rotationMatrix2.m34), Float(rotationMatrix2.m41), Float(rotationMatrix2.m42), Float(rotationMatrix2.m43), Float(rotationMatrix2.m44))
        let glkRotatedVector2 = GLKMatrix4MultiplyVector3WithTranslation(glkMatrix2, glkVector2)
        var rightFeeler = SCNVector3FromGLKVector3(glkRotatedVector2)
        
        // now perform a hit-test based on the seeAhead line segment
        // returns the closest collision object to the owner
        let collisionObjs = owner.levelNode.hitTestWithSegmentFromPoint(owner.presentationNode.position, toPoint: seeAheadPoint, options: nil)
        
        var firstCollisionObj: SCNNode?
        if collisionObjs.count > 0 {
            for collisionObj in collisionObjs {
                if collisionObj.node.name == "wall" {
                    firstCollisionObj = collisionObj.node
                    break
                }
            }
        if let firstObj = firstCollisionObj {
        
        // determine distance to wall
        let directionToWall = VectorMath.getDirectionVector(self.owner.position, finishPoint: firstObj.position)
        let distanceToWall = VectorMath.getVectorMagnitude(directionToWall)
        
        // Calculate avoidance force scalar
        let scalar = (1/distanceToWall)*200
            
        // get wall normal ??
        let globalWallNormal = owner.levelNode.convertPosition(SCNVector3Make(0, 0, 1), fromNode: firstObj.presentationNode)
        
        // avoidance force
        // determined by: collision seeAhead - collision point
        var avoidanceForce = VectorMath.getDirectionVector(firstObj.presentationNode.position, finishPoint: seeAhead)
        
            // normalized the avoidance force and scale by the seeAhead magnitude
        avoidanceForce = VectorMath.getNormalizedVector(avoidanceForce)
        avoidanceForce = VectorMath.multiplyVectorByScalar(avoidanceForce, right: scalar)
        avoidanceForce.y = 0

            steering = VectorMath.addVectorToVector(steering, right: avoidanceForce)
            
                return avoidanceForce
            } else {
            steering = VectorMath.addVectorToVector(steering, right: SCNVector3Make(0, 0, 0))
                return SCNVector3Make(0, 0, 0)
            }
        
        }
        
        steering = VectorMath.addVectorToVector(steering, right: SCNVector3Make(0, 0, 0))
        return SCNVector3Make(0, 0, 0)
    }
    
    func wallAvoidanceOn() {
        bitBehaviors = bitBehaviors | Behavior.WallAvoidance
    }
    
    func wallAvoidanceOff() {
        if on(Behavior.WallAvoidance) {
            bitBehaviors = bitBehaviors ^ Behavior.WallAvoidance
        }
    }
    
    func isWallAvoidanceOn() -> Bool {
        return on(Behavior.WallAvoidance)
    }

    
}
