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
            
            //let enemyFacingDirectionVector: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: normalizedFacingDirection)
            
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
            
            
            //var playerTransform: SCNMatrix4 = rotationRep
            
            
            // Calculate distance to decide on action
            //        let distance = VectorMath.getVectorMagnitude(movementDirection)
            
            //        if distance < self.panicDistance {
            //        // Then take care of translation
            //            playerTransform.m41 = self.presentationNode.position.x + self.steer.flee(target.presentationNode.position).x + self.steer.wallAvoidance().x
            //            playerTransform.m42 = self.presentationNode.position.y
            //            playerTransform.m43 = self.presentationNode.position.z + self.steer.flee(target.presentationNode.position).z + self.steer.wallAvoidance().z
            //            playerTransform.m44 = 1.0
            //
            //        } else {
            //            playerTransform.m41 = self.presentationNode.position.x + self.steer.arrive(target.presentationNode.position).x + self.steer.wallAvoidance().x
            //            playerTransform.m42 = self.position.y + self.steer.arrive(target.presentationNode.position).y + self.steer.wallAvoidance().y
            //            playerTransform.m43 = self.presentationNode.position.z + self.steer.arrive(target.presentationNode.position).z + self.steer.wallAvoidance().z
            //            playerTransform.m44 = 1.0
            //
            //        }
            
            // Set player transform
            //self.transform = playerTransform
            
            let toTarget: SCNVector3 = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
            let distance = VectorMath.getVectorMagnitude(toTarget)
            
                                    switch(distance) {
                                    case 0..<self.panicDistance:
                                        //self.physicsBody?.clearAllForces()
                                        var fleeForce = self.steer.flee(target.presentationNode.position)
                                        fleeForce = VectorMath.getNormalizedVector(fleeForce)
                                        self.physicsBody?.applyForce(fleeForce, impulse: true)
                                    case self.panicDistance..<75:
                                        var arriveForce = self.steer.arrive(target.presentationNode.position)
                                        if arriveForce.x > 0 || arriveForce.y > 0 {
                                        arriveForce = VectorMath.getNormalizedVector(arriveForce)
                                        arriveForce = VectorMath.multiplyVectorByScalar(arriveForce, right: 0.6)
                                        self.physicsBody?.applyForce(arriveForce, impulse: true)
                                        } else {
                                            self.physicsBody?.clearAllForces()
                                        }
                                    default:
                                        // Get direction to wander:
                                        var wanderDirection = self.steer.wander()
                                        let wallAvoidance = self.steer.wallAvoidance()
                                        wanderDirection = VectorMath.addVectorToVector(wanderDirection, right: wallAvoidance)
                                        self.physicsBody?.applyForce(wanderDirection, impulse: true)
            
            //                            let resultingPosition = VectorMath.addVectorToVector(self.presentationNode.position, right: wanderDirection)
            //                            currentMovementDirection = VectorMath.getNormalizedVector(VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: resultingPosition))
                                    }
            
            // Get direction to wander:
            var wanderDirection = self.steer.wander()
            //wanderDirection = VectorMath.getNormalizedVector(wanderDirection)
            let wallAvoidance = self.steer.wallAvoidance()
            wanderDirection = VectorMath.addVectorToVector(wanderDirection, right: wallAvoidance)
            //self.physicsBody?.applyForce(wanderDirection, impulse: true)
            
            //let resultingPosition = VectorMath.addVectorToVector(self.presentationNode.position, right: wanderDirection)
            //currentMovementDirection = VectorMath.getNormalizedVector(VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: resultingPosition))
            
            
            // Now must calculate the rotation direction
            // 1 Determine which way the object is facing
            let facingPoint = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: 10), fromNode: self.presentationNode)
            var facingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: facingPoint)
            facingDirection = VectorMath.getNormalizedVector(facingDirection)
            
            // 2 Determine which way the object should be facing
            //let shouldBeFacingDirection = VectorMath.getNormalizedVector(wanderDirection)
            //let shouldBeFacingDirection = VectorMath.getNormalizedVector((self.physicsBody?.velocity)!)
            
            // get vector towards player
            var shouldBeFacingDirection = VectorMath.getDirectionVector(self.presentationNode.position, finishPoint: self.target.presentationNode.position)
            shouldBeFacingDirection = VectorMath.getNormalizedVector(shouldBeFacingDirection)
            
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
            
            // Wait for a duration, and then shoot
            self.runAction(SCNAction.waitForDuration(3), completionHandler: {
                let bulletGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
                let bulletMaterial = SCNMaterial()
                bulletMaterial.diffuse.contents = NSColor.purpleColor()
                bulletGeometry.materials = [bulletMaterial]
                var bullet = SCNNode(geometry: bulletGeometry)
                bullet.position = SCNVector3Make(self.presentationNode.position.x, 7, self.presentationNode.position.z)
                bullet.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
                bullet.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
                bullet.name = "bullet"
                
                //self.levelNode.addChildNode(bullet)
                
                let shootingDirectionVector = self.levelNode.convertPosition(SCNVector3(x: 0, y: 0, z: -1), fromNode: self.presentationNode)
                
                let impulse = VectorMath.multiplyVectorByScalar(shootingDirectionVector, right: 5)
                
                //bullet.physicsBody?.applyForce(impulse, impulse: true)
            })
            
            
            // rotationAngle is always positive... maybe calculate a difference somehow if it's quicker to turn left or right?
            
            //            if dot > 0 {
            //                print("enemy is facing to the left of the player")
            //                self.physicsBody?.applyTorque(SCNVector4Make(0, -1, 0, rotationAngle), impulse: true)
            //
            //            } else if dotProduct < 0 {
            //                print("enemy is facing to the right of the player")
            //                self.physicsBody?.applyTorque(SCNVector4Make(0, 1, 0, rotationAngle), impulse: true)
            //            }
            
            //oldRotation = self.transform
            
        } else {
            //let fallAction = SCNAction.rotateByAngle(CGFloat(M_PI_2), aroundAxis: SCNVector3Make(-1, 0, 0), duration: 0.1)
            let fadeOut = SCNAction.fadeOutWithDuration(1.0)
            let removeFromParent = SCNAction.removeFromParentNode()
            let sequence = SCNAction.sequence([fadeOut, removeFromParent])
            self.runAction(sequence)
        }
    }
    
}
