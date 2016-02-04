//
//  EnemyFactory.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit



class EnemyFactory: NSObject {
    
    enum EnemyType {
        case LambentMale
        case RobbieRabbit
    }
    
    static func createRobbieRabbit(position: SCNVector3, targets: [Player], levelNode: SCNNode) -> Enemy {
        let robbie = Enemy()
        robbie.health = 100
        robbie.damage = 20
        robbie.speed = 0.4
        robbie.panicDistance = 25
        robbie.viewDistance = 200
        robbie.targets = targets
        robbie.levelNode = levelNode
        
        robbie.spawnAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/evil-giggle.wav")
        robbie.spawnAudioSource?.positional = false
        robbie.spawnAudioSource?.volume = 1.0
        robbie.attackedAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/evil_clown_laugh.mp3")
        robbie.dyingAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/evil_clown_laugh.mp3")
        
        // Get model
        let robbieScene = SCNScene(named: "art.scnassets/Robbie_the_Rabbit_rigged copy.scn")
        let nodeArray = robbieScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            robbie.addChildNode(childNode)
        }
        
        // Set textures"
        robbie.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_d.tga"
        robbie.geometry?.firstMaterial?.specular.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_s.tga"
        robbie.geometry?.firstMaterial?.normal.contents = "art.scnassets/Robbie_the_Rabbit_rigged/Robbie_the_Rabbit_rigged_n.tga"
        
        robbie.position = position
        robbie.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        robbie.physicsBody?.categoryBitMask = ColliderType.Enemy
        robbie.physicsBody?.collisionBitMask =  ColliderType.Ground | ColliderType.Wall | ColliderType.Player | ColliderType.Weapon
        robbie.physicsBody?.contactTestBitMask = ColliderType.PlayerBullet
        robbie.physicsBody?.contactTestBitMask = ColliderType.Player | ColliderType.Weapon
        robbie.physicsBody?.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0)
        robbie.physicsBody?.angularDamping = 0.9
        robbie.physicsBody?.damping = 0.9
        robbie.physicsBody?.restitution = 0
        
        let spawnSoundAction = SCNAction.playAudioSource(robbie.spawnAudioSource!, waitForCompletion: false)
        robbie.runAction(spawnSoundAction)
        
        return robbie
    }
    
    static func createLambentMale(position: SCNVector3, targets: [Player], levelNode: SCNNode) -> Enemy {
        let lambentM = Enemy()
        lambentM.health = 100
        lambentM.damage = 7
        lambentM.speed = 0.4
        lambentM.panicDistance = 25
        lambentM.viewDistance = 100
        lambentM.targets = targets
        lambentM.levelNode = levelNode
        
        lambentM.playerDetectedAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/monster_snarl.mp3")
        lambentM.attackedAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/zombieAttacked.mp3")
        lambentM.dyingAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/zombieDying.mp3")
        lambentM.spawnAudioSource = SCNAudioSource(fileNamed: "art.scnassets/Sounds/zombieSpawn.mp3")
        
        // Get model
        let lambentMScene = SCNScene(named: "art.scnassets/Lambent_Male/Lambent_Male.dae")
        let nodeArray = lambentMScene!.rootNode.childNodes
        
        for childNode in nodeArray {
            // Add model as child node
            childNode.physicsBody = nil
            childNode.scale = SCNVector3Make(5, 5, 5)
            childNode.rotation = SCNVector4Make(-1, 0, 0, CGFloat(M_PI_2))
            lambentM.addChildNode(childNode)
        }
        
        // Set textures"
        lambentM.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/Lambent_Male/Lambent_Male_D.tga"
        lambentM.geometry?.firstMaterial?.specular.contents = "art.scnassets/Lambent_Male/Lambent_Male_S.tga"
        lambentM.geometry?.firstMaterial?.normal.contents = "art.scnassets/Lambent_Male/Lambent_Male_N.tga"
        lambentM.geometry?.firstMaterial?.emission.contents = "art.scnassets/Lambent_Male/Lambent_Male_E.tga"
        
        lambentM.position = position
        
        lambentM.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        lambentM.physicsBody?.categoryBitMask = ColliderType.Enemy
        lambentM.physicsBody?.collisionBitMask =  ColliderType.Ground | ColliderType.Wall | ColliderType.Player | ColliderType.Weapon
        lambentM.physicsBody?.contactTestBitMask = ColliderType.PlayerBullet | ColliderType.Player | ColliderType.Weapon
        lambentM.physicsBody?.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0)
        lambentM.physicsBody?.angularDamping = 0.9
        lambentM.physicsBody?.damping = 0.9
        lambentM.physicsBody?.restitution = 0
        
        let spawnSoundAction = SCNAction.playAudioSource(lambentM.spawnAudioSource!, waitForCompletion: false)
        lambentM.runAction(spawnSoundAction)
        
        return lambentM
    }
}
