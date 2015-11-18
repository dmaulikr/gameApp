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
    
    override init() {
        super.init()
        
        stateMachine = AIStateMachine(owner: self)
        steer = SteeringBehaviors(owner: self)
        oldRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        dead = false
        currentMovementDirection = SCNVector3Make(0, 0, 0)
        //wanderTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "updateWander", userInfo: nil, repeats: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateWander() {
        let wanderAction = SCNAction.moveTo(self.steer.wander(), duration: 4.0)
        self.runAction(wanderAction)
    }
    
    func update() {
        
        if dead == false {
        // Get enemy heading in world space
        let forwardFacingEnemyCoordinates = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: self.presentationNode)
        let normalizedFacingDirection = VectorMath.getNormalizedVector(forwardFacingEnemyCoordinates)
        
        // Get the necessary movement direction vector
        let movementDirection: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
        let movementDirectionNormalized = VectorMath.getNormalizedVector(movementDirection)
        
        let enemyFacingDirectionVector: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: normalizedFacingDirection)
        
        // Calculate dot product
        let dotProduct = VectorMath.dotProduct(normalizedFacingDirection, right: movementDirectionNormalized)
        
        // rotation axis:
        let rotAxis = VectorMath.crossProduct(normalizedFacingDirection, right: movementDirectionNormalized)
        
        // calculate rotation angle:
        let rotAngle = acos(dotProduct)
        
        let rotationRep = SCNMatrix4MakeRotation(rotAngle, 0, rotAxis.y, 0)
        
        //var matrixRotationRep: SCNMatrix4
        
//        if dotProduct > 0 {
//            print("enemy is facing to the left of the player")
//            matrixRotationRep = SCNMatrix4MakeRotation(targetRotation, 0, -1, 0)
//            
//        } else if dotProduct < 0 {
//            print("enemy is facing to the right of the player")
//            matrixRotationRep = SCNMatrix4MakeRotation(targetRotation, 0, 1, 0)
//            targetRotation = -targetRotation
//        } else {
//            print("enemy is facing the player")
//            matrixRotationRep = SCNMatrix4MakeRotation(0, 0, 0, 0)
//        }
        
        //print("normalizedEnemyFacingDirection: \(normalizedFacingDirection)")
        //print("movementDirectionNormalized: \(movementDirectionNormalized)")
        //print("matrixRotationRep: \(matrixRotationRep)")

        //self.eulerAngles = SCNVector3Make(0, targetRotation, 0)
        
        //self.eulerAngles = VectorMath.addVectorToVector(self.eulerAngles, right: eulerRepresentation)
        
        //self.position = VectorMath.addVectorToVector(self.position, right: self.steer.arrive(target.presentationNode.position))
        
        //oldRotation = self.rotation
        
        //var playerTransform = SCNMatrix4Mult(oldRotation!, matrixRotationRep)
        
        
        var playerTransform: SCNMatrix4 = rotationRep
        
        
        // Calculate distance to decide on action
        let distance = VectorMath.getVectorMagnitude(movementDirection)
        
        if distance < self.panicDistance {
        // Then take care of translation
            playerTransform.m41 = self.presentationNode.position.x + self.steer.flee(target.presentationNode.position).x + self.steer.wallAvoidance().x
            playerTransform.m42 = self.presentationNode.position.y
            playerTransform.m43 = self.presentationNode.position.z + self.steer.flee(target.presentationNode.position).z + self.steer.wallAvoidance().z
            playerTransform.m44 = 1.0
        
        } else {
            playerTransform.m41 = self.presentationNode.position.x + self.steer.arrive(target.presentationNode.position).x + self.steer.wallAvoidance().x
            playerTransform.m42 = self.position.y + self.steer.arrive(target.presentationNode.position).y + self.steer.wallAvoidance().y
            playerTransform.m43 = self.presentationNode.position.z + self.steer.arrive(target.presentationNode.position).z + self.steer.wallAvoidance().z
            playerTransform.m44 = 1.0
            
        }
        
        // Set player transform
        //self.transform = playerTransform
        
        // Get direction to wander:
        var wanderDirection = self.steer.wander()
        print("wanderDirection: \(wanderDirection)")
        wanderDirection = VectorMath.getNormalizedVector(wanderDirection)
        wanderDirection = VectorMath.multiplyVectorByScalar(wanderDirection, right: 0.5)
        //wanderDirection = VectorMath.addVectorToVector(wanderDirection, right: self.steer.wallAvoidance())
        //wanderDirection = VectorMath.getNormalizedVector(wanderDirection)
        let resultingPosition = VectorMath.addVectorToVector(self.presentationNode.position, right: wanderDirection)
        //let resultingPositionScaled = VectorMath.multiplyVectorByScalar(resultingPosition, right: 1.1)
        currentMovementDirection = VectorMath.getNormalizedVector(VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: resultingPosition))
        let wanderAction = SCNAction.moveTo(resultingPosition, duration: 5.0)
            self.physicsBody?.applyForce(wanderDirection, impulse: true)
        //self.runAction(wanderAction)
        
        oldRotation = self.transform
            
        } else {
            //let fallAction = SCNAction.rotateByAngle(CGFloat(M_PI_2), aroundAxis: SCNVector3Make(-1, 0, 0), duration: 0.1)
            let fadeOut = SCNAction.fadeOutWithDuration(1.0)
            let removeFromParent = SCNAction.removeFromParentNode()
            let sequence = SCNAction.sequence([fadeOut, removeFromParent])
            self.runAction(sequence)
        }
    }
    
}
