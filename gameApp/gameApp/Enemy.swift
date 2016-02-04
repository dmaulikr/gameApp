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
    static let attack = "attack"
}

class Enemy: SCNNode {
    
    var health: Int!
    var damage: Int!
    var speed: CGFloat!
    var panicDistance: CGFloat!
    var viewDistance: CGFloat!
    var attackDistance: CGFloat!
    var attackForce: CGFloat!
    var attackBreak: Double!
    var latestAttack: NSTimeInterval!
    var fieldOfView: Double!
    var steer: SteeringBehaviors!
    var targets = [Player]()
    var currentTarget: Player?
    var levelNode: SCNNode!
    var oldRotation: SCNMatrix4!
    var dead: Bool!
    var wanderTimer: NSTimer!
    var currentMovementDirection: SCNVector3!
    var state: String!
    
    var playerDetectedAudioSource: SCNAudioSource?
    var attackedAudioSource: SCNAudioSource?
    var dyingAudioSource: SCNAudioSource?
    var spawnAudioSource: SCNAudioSource?
    
    override init() {
        super.init()
        
        steer = SteeringBehaviors(owner: self)
        oldRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        dead = false
        currentMovementDirection = SCNVector3Make(0, 0, 0)
        state = State.wander
        fieldOfView = M_PI
        viewDistance = 1000
        attackDistance = 20
        attackForce = 2.5
        attackBreak = 2.5
        latestAttack = 0.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(time: NSTimeInterval) {
        if self.dead == false {
            self.updateCurrentTarget()
            self.updateState()
                self.performRotation()
                self.executeState(time)
        }
    }
    
    func facingDirection() -> SCNVector3 {
        let facingPoint = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: 10), fromNode: self.presentationNode)
        let facingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: facingPoint)
        return VectorMath.getNormalizedVector(facingDirection)
    }
    
    func inFieldOfView(node: Player) -> Bool
    {
        let facingDirection = self.facingDirection()
        
        let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: node.presentationNode.position)
        let distance = VectorMath.getVectorMagnitude(toTarget)
        
       // if VectorMath.dotProduct(facingDirection, right: toTarget) >= 0
        //{
            if distance < self.viewDistance {
                // Then check if there is anything else between enemy and player
                let collisionObjs = self.levelNode.hitTestWithSegmentFromPoint(self.presentationNode.position, toPoint: node.presentationNode.position, options: nil)
                
                if collisionObjs.count > 0 {
                    for collisionObj in collisionObjs {
                        if collisionObj.node.name == "wall" {
                            return false
                        }
                    }
                }
                return true
            } else {
                return false
            }
        //} else {
          //  return false
        //}
    }
    
    func updateCurrentTarget() {
        //var closestTarget = targets[0] // automatically
        // Not adding closestTarget will cause BAD_ACCESS_EXC
        var closestTarget: Player?
        var closestDistance = self.viewDistance+1
        for target in self.targets {
            if inFieldOfView(target) {
                let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: target.presentationNode.position)
                let distance = VectorMath.getVectorMagnitude(toTarget)
                if distance < closestDistance {
                    closestDistance = distance
                    closestTarget = target
                }
            }
        }
        currentTarget = closestTarget
    }
    
    func updateState() {
        if let currTarget = currentTarget {
            let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: currTarget.presentationNode.position)
            let distance = VectorMath.getVectorMagnitude(toTarget)
            print("distance: \(distance)")
            print("self.attackDistance: \(attackDistance)")
            switch(distance) {
            case 0..<self.attackDistance:
                self.state = State.attack
                print("attack state")
            case self.attackDistance+3..<self.viewDistance+1:
                self.state = State.arrive
                print("arrive state")
            default:
                self.state = State.wander
                print("wander state")
            }
        } else {
            self.state = State.wander
            print("wander state")
        }
    }
    
    func executeState(time: NSTimeInterval) {
        switch(self.state) {
        case State.attack:
            // Propel physics body towards player
            if time - self.latestAttack > self.attackBreak {
                let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.currentTarget!.presentationNode.position)
                let distance = VectorMath.getVectorMagnitude(toTarget)
                var attackDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.currentTarget!.presentationNode.position)
                attackDirection = VectorMath.getNormalizedVector(attackDirection)
                self.physicsBody?.applyForce(VectorMath.multiplyVectorByScalar(attackDirection, right: distance*self.attackForce) , impulse: true)
                
                // after, move back wards
                let waitAction = SCNAction.waitForDuration(0.5)
                let moveBackwardsAction = SCNAction.runBlock({(SCNNode) -> Void in
                    if let target = self.currentTarget {
                        var fleeDirection = VectorMath.getDirectionVector(target.presentationNode.position, finishPoint: self.presentationNode.position)
                        fleeDirection = VectorMath.getNormalizedVector(fleeDirection)
                        let fleeForce = VectorMath.multiplyVectorByScalar(fleeDirection, right: distance/2)
                        self.physicsBody?.applyForce(fleeForce, impulse: true)
                    }
                })
                let actionSequence = SCNAction.sequence([waitAction,moveBackwardsAction])
                self.runAction(actionSequence)
                
                self.latestAttack = time
            }
        case State.flee:
            var fleeForce = self.steer.flee(self.currentTarget!.presentationNode.position)
            fleeForce = VectorMath.getNormalizedVector(fleeForce)
            self.physicsBody?.applyForce(fleeForce, impulse: true)
        case State.arrive:
            var arriveForce = self.steer.arrive(self.currentTarget!.presentationNode.position)
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
        let facingDirection = self.facingDirection()
        
        // 2 Determine which way the object should be facing
        var shouldBeFacingDirection: SCNVector3
        
        if self.state == State.wander {
            shouldBeFacingDirection = VectorMath.getNormalizedVector((self.physicsBody?.velocity)!)
        } else {
            // otherwise should be facing player
            shouldBeFacingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.currentTarget!.presentationNode.position)
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
            self.physicsBody?.applyTorque(SCNVector4Make(rotationAxis.x, rotationAxis.y, rotationAxis.z, rotationAngle), impulse: true)
        } else {
            self.physicsBody?.clearAllForces()
        }
    }
    
    func applyDamage(damage: Int) {
        if self.dead == false {
            self.health = self.health - damage
            let attackedSoundAction = SCNAction.playAudioSource(attackedAudioSource!, waitForCompletion: false)
            self.runAction(attackedSoundAction)
            if health <= 0 {
                let dyingSoundAction = SCNAction.playAudioSource(dyingAudioSource!, waitForCompletion: false)
                let sendEnemyDeadNotificationAction = SCNAction.runBlock({(SCNNode) -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.enemyDead, object: self, userInfo: ["enemy": self])
                })
                let actionSequence = SCNAction.sequence([dyingSoundAction,sendEnemyDeadNotificationAction])
                self.runAction(actionSequence)
                dead = true
            }
        }
    }
}
