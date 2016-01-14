//
//  GameSimulation.swift
//  gameApp
//
//  Created by Liza Girsova on 10/28/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

struct ColliderType {
    static let Player = 0x1 << 0 // 1
    static let Enemy = 0x1 << 1 // 2
    static let Ground = 0x1 << 2 // 4
    static let Weapon = 0x1 << 3 // 8
    static let PlayerBullet = 0x1 << 4 // 16
    static let Wall = 0x1 << 5 // 32
    static let EnemyBullet = 0x1 << 6 // 64
}

struct Keystroke {
    enum InteractionType {
        case Button
        case Trackpad
    }
    enum TrackpadType {
        case Movement
        case Camera
    }
    enum GestureType {
        case Tap
        case Pan
    }
    enum Button {
        case Crouch
        case Attack
        case Interact
    }
    
    var interactionType: InteractionType?
    var trackpadType: TrackpadType?
    var gestureType: GestureType?
    var button: Button?
    var panTranslation: CGPoint?
    var panStart: Bool?
    
    init() {
        self.interactionType = nil
    }
    
    init(interactionType: InteractionType) {
        self.interactionType = interactionType
    }
}

class GameSimulation: SCNScene {
    
    var gameLevel: GameLevel!
    
    override init() {
        super.init()
        
        self.physicsWorld.contactDelegate = self
        self.gameLevel = GameLevel()
        let levelNode: SCNNode = gameLevel.createLevel(self)
        self.rootNode.addChildNode(levelNode)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerControls:", name: Constants.Notifications.playerControls, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func playerControls(notification: NSNotification) {
        let userInfo:Dictionary<String,NSObject!> = notification.userInfo as! Dictionary<String,NSObject!>
        let data = userInfo["strokeInfo"] as! NSData
        let mcPeerID = userInfo["peerID"]
        let peer = ConnectedPeers.dict.objectForKey(mcPeerID!) as! Peer
        
        var strokeInfo: Keystroke = Keystroke()
        data.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        switch strokeInfo.interactionType! {
        case .Trackpad:
            
            switch strokeInfo.trackpadType! {
                
            case .Movement:
                switch strokeInfo.gestureType! {
                case .Pan:
                    if strokeInfo.panTranslation != nil {
                        //print("Movement pan is not nil")
                        gameLevel.calculatePlayerMovementTransform(peer.player!.id!, panx: strokeInfo.panTranslation!.x, pany: strokeInfo.panTranslation!.y)
                    } else {
                        //print("Game Sim: player not moving")
                        gameLevel.calculatePlayerMovementTransform(peer.player!.id!, panx: 0, pany: 0)
                    }
                default: break
                }
            case .Camera:
                switch strokeInfo.gestureType! {
                case .Tap:
                    gameLevel.jump(peer.player!.id!)
                case .Pan:
                    // Change camera view
                    if strokeInfo.panTranslation != nil {
                        //print("Camera pan is not nil")
                        gameLevel.calculateCameraRotationTransform(peer.player!.id!, panx: strokeInfo.panTranslation!.x, pany: strokeInfo.panTranslation!.y)
                    } else {
                        // No rotations must happen anymore
                        gameLevel.calculateCameraRotationTransform(peer.player!.id!, panx: 0, pany: 0)
                    }
                }
            }
        case .Button:
            switch strokeInfo.button! {
            case .Crouch:
                print("the button event was crouch")
            case .Attack:
                
                gameLevel.playerAttack(peer.player!.id!)
                
            case .Interact:
                print ("the button event was interact")
            }
        }
    }
}

extension GameSimulation : SCNSceneRendererDelegate {
    func renderer(renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // add code
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        gameLevel.updatePlayersTransform()
        gameLevel.updateCrosshairAim()
        gameLevel.updateEnemy()
        
    }
    
    func renderer(renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        // Add code
    }
    
    func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        // Add code
    }
}

extension GameSimulation : SCNPhysicsContactDelegate {
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        switch contactMask {
        case ColliderType.Player | ColliderType.Enemy:
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.Enemy {
                let enemy = contact.nodeA as! Enemy
                let player = contact.nodeB as! Player
                if player.startedEnemyContact == false {
                    player.startedEnemyContact = true
                    gameLevel.subtractPlayerHealth(player.id!, damage: enemy.damage)
                }
            } else {
                let enemy = contact.nodeB as! Enemy
                let player = contact.nodeA as! Player
                if player.startedEnemyContact == false {
                    player.startedEnemyContact = true
                    gameLevel.subtractPlayerHealth(player.id!, damage: enemy.damage)
                }
            }
        case ColliderType.Enemy | ColliderType.Weapon:
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.Enemy {
                let enemy = contact.nodeA as! Enemy
                let weapon = contact.nodeB as! Weapon
                if weapon.startedEnemyContact == false {
                    weapon.startedEnemyContact = true
                    gameLevel.subtractPlayerHealth(weapon.owner!.id!, damage: enemy.damage)
                }
            } else {
                let enemy = contact.nodeB as! Enemy
                let weapon = contact.nodeA as! Weapon
                if weapon.startedEnemyContact == false {
                    weapon.startedEnemyContact = true
                    gameLevel.subtractPlayerHealth(weapon.owner!.id!, damage: enemy.damage)
                }
            }
            
        case ColliderType.Player | ColliderType.EnemyBullet:
            break;
            // calculate the damage to the player
        case ColliderType.PlayerBullet | ColliderType.Enemy:
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.PlayerBullet {
                let bullet = contact.nodeA
                if bullet.parentNode != nil {
                    gameLevel.subtractEnemyHealth()
                }
                bullet.geometry?.firstMaterial?.normal.contents = nil
                bullet.geometry?.firstMaterial?.diffuse.contents = nil
                bullet.removeFromParentNode()
            } else {
                let bullet = contact.nodeB
                if bullet.parentNode != nil {
                    gameLevel.subtractEnemyHealth()
                }
                bullet.geometry?.firstMaterial?.normal.contents = nil
                bullet.geometry?.firstMaterial?.diffuse.contents = nil
                bullet.removeFromParentNode()
            }
        case ColliderType.PlayerBullet | ColliderType.Ground:
            break
        case ColliderType.Wall | ColliderType.Weapon:
            print("collision between wall and weapon")
        default: break
        }
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        switch contactMask {
        case ColliderType.Player | ColliderType.Enemy:
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.Player {
                let player = contact.nodeA as! Player
                player.startedEnemyContact = false
            } else {
                let player = contact.nodeB as! Player
                player.startedEnemyContact = false
            }
        case ColliderType.Enemy | ColliderType.Weapon:
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.Weapon {
                let weapon = contact.nodeA as! Weapon
                weapon.startedEnemyContact = false
            } else {
                let weapon = contact.nodeB as! Weapon
                weapon.startedEnemyContact = false
            }
        default:
            break;
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        // add code
    }
}

