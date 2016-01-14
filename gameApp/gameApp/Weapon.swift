//
//  Weapon.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Weapon: SCNNode {
    
    var baseDamage: CGFloat?
    var ammoLoaded: CGFloat?
    var ammoCarried: CGFloat?
    var attackInterval: NSTimeInterval?
    var reloadTime: NSTimeInterval?
    var type: WeaponType?
    var startedEnemyContact: Bool!
    var bulletAudioSource: SCNAudioSource?
    var bullet: SCNNode?
    var owner: Player?
    
    override init() {
        super.init()
        startedEnemyContact = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func fire(direction: SCNVector3) {
        let bulletSoundAction = SCNAction.playAudioSource(bulletAudioSource!, waitForCompletion: false)
        self.runAction(bulletSoundAction)
        
        let bulletGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 1)
        let bulletMaterial = SCNMaterial()
        bulletMaterial.diffuse.contents = NSColor.orangeColor()
        bulletGeometry.materials = [bulletMaterial]
        let bullet = SCNNode(geometry: bulletGeometry)
        bullet.position = owner!.levelNode.convertPosition(owner!.ownCameraNode().presentationNode.position, fromNode: owner!)
        bullet.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: bulletGeometry, options: nil))
        bullet.physicsBody?.velocityFactor = SCNVector3Make(1, 0.5, 1)
        bullet.physicsBody?.categoryBitMask = ColliderType.PlayerBullet
        bullet.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Ground
        bullet.physicsBody?.contactTestBitMask = ColliderType.Enemy | ColliderType.Player | ColliderType.Ground | ColliderType.Wall
        bullet.name = "bullet"
        
        owner!.levelNode.addChildNode(bullet)
        
        let impulse = VectorMath.multiplyVectorByScalar(direction, right: 700)
        
        bullet.physicsBody?.applyForce(impulse, impulse: true)
    }
    
}
