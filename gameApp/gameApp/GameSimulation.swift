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
    static let Bullet = 0x1 << 4 // 16
    static let Wall = 0x1 << 5 // 32
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

    let kPlayerControlsNK = "elg-playerControls"
    var gameLevel: GameLevel!

    override init() {
        super.init()
        
        self.physicsWorld.contactDelegate = self
        self.gameLevel = GameLevel()
        let levelNode: SCNNode = gameLevel.createLevel(self)
        self.rootNode.addChildNode(levelNode)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerControls:", name: kPlayerControlsNK, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func playerControls(notification: NSNotification) {
        let userInfo:Dictionary<String,NSData!> = notification.userInfo as! Dictionary<String,NSData!>
        let data = userInfo["strokeInfo"]
        
        var strokeInfo: Keystroke = Keystroke()
        data!.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        switch strokeInfo.interactionType! {
        case .Trackpad:
            
            switch strokeInfo.trackpadType! {
                
            case .Movement:
                switch strokeInfo.gestureType! {
                case .Pan:
                    if strokeInfo.panTranslation != nil {
                        //print("Movement pan is not nil")
                        gameLevel.calculatePlayerMovementTransform(strokeInfo.panTranslation!.x, pany: strokeInfo.panTranslation!.y)
                    } else {
                        //print("Game Sim: player not moving")
                        gameLevel.playerNotMoving()
                    }
                default: break
                }
            case .Camera:
                switch strokeInfo.gestureType! {
                case .Tap:
                    gameLevel.player.jump()
                case .Pan:
                    // Change camera view
                    if strokeInfo.panTranslation != nil {
                        //print("Camera pan is not nil")
                       gameLevel.calculateCameraRotationTransform(strokeInfo.panTranslation!.x, pany: strokeInfo.panTranslation!.y)
                    } else {
                        // No rotations must happen anymore
                        //print("Game Sim: camera not panning")
                        gameLevel.cameraNotRotating()
                    }
                }
            }
        case .Button:
            switch strokeInfo.button! {
            case .Crouch:
                print("the button event was crouch")
            case .Attack:
                
                gameLevel.playerAttack()
                                
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
        gameLevel.updatePlayerTransform()
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
            print("collision between player and enemy")
        case ColliderType.Player | ColliderType.Bullet:
            print("collision between player and bullet")
            
            // calculate the damage to the player
            
        case ColliderType.Weapon | ColliderType.Enemy:
            print("collision between weapon and enemy")
        case ColliderType.Bullet | ColliderType.Enemy:
            print("collision between bullet and enemy")
            if contact.nodeA.physicsBody!.categoryBitMask == ColliderType.Bullet {
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
        case ColliderType.Bullet | ColliderType.Ground:
            break
        case ColliderType.Ground | ColliderType.Enemy:
            print("collision between ground and enemy")
        case ColliderType.Ground | ColliderType.Player:
            print("collision between ground and player")
        case ColliderType.Wall | ColliderType.Enemy:
            print("collision between wall and enemy")
        case ColliderType.Wall | ColliderType.Player:
            print("collision between wall and player")
        case ColliderType.Wall | ColliderType.Weapon:
            print("collision between wall and weapon")
        case ColliderType.Wall | ColliderType.Bullet:
            print("collision between wall and bullet")
        default: break
        }
        
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact) {
        // add code
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        // add code
    }
}

