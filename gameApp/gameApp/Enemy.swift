//
//  Enemy.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

struct State {
    static let arrive = "arrive"
    static let flee = "flee"
    static let wander = "wander"
}

class Enemy: SCNNode {
    
    var health: CGFloat!
    var damage: CGFloat!
    var speed: CGFloat!
    var panicDistance: CGFloat!
    var viewDistance: CGFloat!
    var stateMachine: AIStateMachine<Enemy>?
    var steer: SteeringBehaviors!
    var target: Player!
    var levelNode: SCNNode!
    var oldRotation: SCNMatrix4!
    var dead: Bool!
    var wanderTimer: NSTimer!
    var currentMovementDirection: SCNVector3!
    var state: String!
    
    override init() {
        super.init()
        
        stateMachine = AIStateMachine(owner: self)
        steer = SteeringBehaviors(owner: self)
        oldRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        dead = false
        currentMovementDirection = SCNVector3Make(0, 0, 0)
        state = State.wander
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update() {
        
        if dead == false {
            
            self.updateState()
            self.performRotation()
            self.performMovement()
            
        } else {
            // DEAD
            self.physicsBody?.angularVelocityFactor = SCNVector3Make(1.0, 1.0, 0.0)
            self.physicsBody?.applyTorque(SCNVector4Make(-1,0,0, CGFloat(M_PI_2)), impulse: true)
            let fadeOut = SCNAction.fadeOutWithDuration(1.0)
            let removeFromParent = SCNAction.removeFromParentNode()
            let sequence = SCNAction.sequence([fadeOut, removeFromParent])
            self.runAction(sequence)
        }
    }
    
    func updateState() {
        let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
        let distance = VectorMath.getVectorMagnitude(toTarget)
        
        switch(distance) {
        case 0..<self.panicDistance:
            self.state = State.flee
        case self.panicDistance..<75:
            self.state = State.arrive
        default:
            self.state = State.wander
        }
    }
    
    func performMovement() {
        let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
        let distance = VectorMath.getVectorMagnitude(toTarget)
        
        switch(self.state) {
        case State.flee:
            var fleeForce = self.steer.flee(target.presentationNode.position)
            fleeForce = VectorMath.getNormalizedVector(fleeForce)
            self.physicsBody?.applyForce(fleeForce, impulse: true)
        case State.arrive:
            var arriveForce = self.steer.arrive(target.presentationNode.position)
            if arriveForce.x > 0 || arriveForce.y > 0 {
                arriveForce = VectorMath.getNormalizedVector(arriveForce)
                arriveForce = VectorMath.multiplyVectorByScalar(arriveForce, right: 0.8)
                self.physicsBody?.applyForce(arriveForce, impulse: true)
            } else  {
                self.physicsBody?.clearAllForces()
            }
        default:
            // Get direction to wander:
            var wanderDirection = self.steer.wander()
            let wallAvoidance = self.steer.wallAvoidance()
            wanderDirection = VectorMath.addVectorToVector(wanderDirection, right: wallAvoidance)
            self.physicsBody?.applyForce(wanderDirection, impulse: true)
        }
    }
    
    func performRotation() {
        // 1 Determine which way the object is facing
        let facingPoint = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: 10), fromNode: self.presentationNode)
        var facingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: facingPoint)
        facingDirection = VectorMath.getNormalizedVector(facingDirection)
        
        // 2 Determine which way the object should be facing
        var shouldBeFacingDirection: SCNVector3
        
        if self.state == State.wander {
            shouldBeFacingDirection = VectorMath.getNormalizedVector((self.physicsBody?.velocity)!)
        } else {
            // otherwise should be facing player
            shouldBeFacingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
            shouldBeFacingDirection = VectorMath.getNormalizedVector(shouldBeFacingDirection)
        }
        
        // 3 Determine the angle between those directions
        let dot = VectorMath.dotProduct(facingDirection, right: shouldBeFacingDirection)
        let rotationAngle = acos(dot)
        
        // 4 Determine the rotation axis
        var rotationAxis = VectorMath.crossProduct(facingDirection, right: shouldBeFacingDirection)
        rotationAxis = VectorMath.getNormalizedVector(rotationAxis)
        
        // 5 Rotate object about rotationAxis by rotationAngle
        if VectorMath.radiansToDegrees(rotationAngle) > 10 {
            if rotationAxis.y < 0 {
                self.physicsBody?.applyTorque(SCNVector4Make(rotationAxis.x, rotationAxis.y, rotationAxis.z, rotationAngle), impulse: true)
            } else  {
                self.physicsBody?.applyTorque(SCNVector4Make(rotationAxis.x, rotationAxis.y, rotationAxis.z, rotationAngle), impulse: true)
            }
        } else {
            self.physicsBody?.clearAllForces()
        }
    }
}
