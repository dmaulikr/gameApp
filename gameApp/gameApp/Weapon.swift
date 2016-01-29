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
    
    var baseDamage: Int?
    var ammoLoadedMax: Int?
    var ammoCarriedMax: Int?
    var ammoLoaded: Int?
    var ammoCarried: Int?
    var attackInterval: NSTimeInterval?
    var reloadTime: NSTimeInterval?
    var type: WeaponType?
    var startedEnemyContact: Bool!
    var bulletAudioSource: SCNAudioSource?
    var outOfAmmoAudioSource: SCNAudioSource?
    var reloadAudioSource: SCNAudioSource?
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
        if self.ammoLoaded > 0 {
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
            self.ammoLoaded = self.ammoLoaded!-1
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.updateHUD, object: self, userInfo: ["playerID": self.owner!.id!.hashValue, "ammoCarried": self.ammoCarried!, "ammoLoaded" : self.ammoLoaded!])
        } else {
            // Play empty gun sound
            let outOfAmmoSoundAction = SCNAction.playAudioSource(outOfAmmoAudioSource!, waitForCompletion: false)
            self.runAction(outOfAmmoSoundAction)
        }
    }
    
    func reload() {
        if !(self.ammoCarried == self.ammoCarriedMax && self.ammoLoaded == self.ammoLoadedMax) {
        if self.ammoCarried >= self.ammoLoadedMax {
            self.ammoLoaded = self.ammoLoadedMax
            self.ammoCarried = self.ammoCarried! - self.ammoLoaded!
        } else if self.ammoCarried > 0 {
            self.ammoLoaded = self.ammoCarried
            self.ammoCarried = self.ammoCarried! - self.ammoLoaded!
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.updateHUD, object: self, userInfo: ["playerID": self.owner!.id!.hashValue, "ammoCarried": self.ammoCarried!, "ammoLoaded" : self.ammoLoaded!])
            let reloadSoundAction = SCNAction.playAudioSource(reloadAudioSource!, waitForCompletion: false)
            self.runAction(reloadSoundAction)
        }
    }
    
}
