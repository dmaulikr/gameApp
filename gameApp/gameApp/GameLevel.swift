//
//  GameLevel.swift
//  gameApp
//
//  Created by Liza Girsova on 10/28/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class GameLevel: NSObject {
    var currentLevel: Level!
    var ground: SCNNode!
    var light: SCNNode!
    var latestSpawn: NSTimeInterval!
    
    override init() {
        super.init()
    }
    
    func createLevel(parentScene: SCNScene, level: String) -> SCNNode {
        
        switch level {
            case "horror":
            currentLevel = LevelFactory.createHorrorLevel(parentScene)
            case "extremeHorror":
            currentLevel = LevelFactory.createExtremeHorrorLevel(parentScene)
        default: break
        }
        
        if let soundtrack = currentLevel.soundtrackAudioSource {
            let soundtrackAction = SCNAction.playAudioSource(soundtrack, waitForCompletion: false)
            currentLevel.worldNode.runAction(soundtrackAction)
        }
        
        latestSpawn = 0.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTracesOfDeadPlayer:", name: Constants.Notifications.playerDead, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTracesOfDeadEnemy:", name: Constants.Notifications.enemyDead, object: nil)
        
        return currentLevel.worldNode
    }
    
    func playerAttack(playerID: Player.ID) {
        if let player = currentLevel.playerDict.objectForKey(playerID.hashValue){
        (player as! Player).playerAttack()
        }
    }
    
    func calculatePlayerMovementTransform(playerID: Player.ID, panx: CGFloat, pany: CGFloat) {
        if let player = currentLevel.playerDict.objectForKey(playerID.hashValue){
        (player as! Player).calculateMovementTransform(panx, pany: pany)
        }
    }
    
    func calculateCameraRotationTransform(playerID: Player.ID, panx: CGFloat, pany: CGFloat) {
        if let player = currentLevel.playerDict.objectForKey(playerID.hashValue){
            (player as! Player).calculateRotationTransform(panx, pany: pany)
        }
    }
    
    func rotatePlayer180Degrees(playerID: Player.ID) {
        (currentLevel.playerDict.objectForKey(playerID.hashValue) as! Player).rotate180Degrees()
    }
    
    func updateCrosshairAim(){
        if let player1 = currentLevel.playerDict.objectForKey(Player.ID.ID1.hashValue) {
            (player1 as! Player).updateCrosshairAim()
        }
        
        if let player2 = currentLevel.playerDict.objectForKey(Player.ID.ID2.hashValue) {
            (player2 as! Player).updateCrosshairAim()
        }
    }
    
    func damageEnemy(enemy: Enemy) {
        if let player1 = currentLevel.playerDict.objectForKey(Player.ID.ID1.hashValue) {
            enemy.applyDamage((player1 as! Player).equippedWeapon!.baseDamage!+(player1 as! Player).damage)
        } else {
            let player2 = currentLevel.playerDict.objectForKey(Player.ID.ID2.hashValue)
            enemy.applyDamage((player2 as! Player).equippedWeapon!.baseDamage!+(player2 as! Player).damage)
        }
    }
    
    func updateAllEnemies(time: NSTimeInterval) {
        for enemy in currentLevel.enemyArray {
            enemy.update(time)
        }
    }
    
    func updatePlayersTransform() {
        if let player1 = currentLevel.playerDict.objectForKey(Player.ID.ID1.hashValue) {
            (player1 as! Player).updatePlayerTransform()
        }
        
        if let player2 = currentLevel.playerDict.objectForKey(Player.ID.ID2.hashValue) {
            (player2 as! Player).updatePlayerTransform()
        }
    }
    
    func damagePlayer(playerID: Player.ID, enemy: Enemy) {
        // Calculate damage level
        let damage = Int(arc4random_uniform(UInt32(enemy.damage)))
        if let player = currentLevel.playerDict.objectForKey(playerID.hashValue) {
        (player as! Player).subtractPlayerHealth(damage)
        }
    }
    
    func inventoryBoosterForPlayer(playerID: Player.ID, inventoryItem: InventoryItem) {
         if let player = currentLevel.playerDict.objectForKey(playerID.hashValue) {
        (player as! Player).equipBooster(inventoryItem)
        }
    }
    
    func jump(playerID: Player.ID) {
        (currentLevel.playerDict.objectForKey(playerID.hashValue) as! Player).jump()
    }
    
    func playerReloadWeapon(playerID: Player.ID) {
         if let player = currentLevel.playerDict.objectForKey(playerID.hashValue) {
        (player as! Player).reloadWeapon()
        }
    }
    
    func removeTracesOfDeadPlayer(notification: NSNotification) {
        let dict:Dictionary<String,AnyObject> = notification.userInfo as! Dictionary<String,AnyObject>
        let playerIDHash = dict["playerID"] as! Int
        
        // First remove from all enemy list
        for enemy in currentLevel.enemyArray {
            for (index, value) in enemy.targets.enumerate() {
                if value.id?.hashValue == playerIDHash {
                    enemy.targets.removeAtIndex(index)
                }
            }
        }
        
        // Then remove from parent node
        let deadPlayer = (currentLevel.playerDict.objectForKey(playerIDHash) as! Player)
        deadPlayer.removeAllActions()
        deadPlayer.removeFromParentNode()
        
        // Remove from dict
        currentLevel.playerDict.removeObjectForKey(playerIDHash)
    }
    
    func removeTracesOfDeadEnemy(notification: NSNotification) {
        let dict:Dictionary<String,AnyObject> = notification.userInfo as! Dictionary<String,AnyObject>
        let deadEnemy = dict["enemy"] as! Enemy
        
        for (index, enemy) in currentLevel.enemyArray.enumerate() {
            if enemy.isEqual(deadEnemy){
            currentLevel.enemyArray.removeAtIndex(index)
            enemy.physicsBody?.angularVelocityFactor = SCNVector3Make(1.0, 1.0, 0.0)
            enemy.physicsBody?.applyTorque(SCNVector4Make(-1,0,0, CGFloat(M_PI_2)), impulse: true)
            let fadeOut = SCNAction.fadeOutWithDuration(1.0)
            let removeFromParent = SCNAction.removeFromParentNode()
            let sequence = SCNAction.sequence([fadeOut, removeFromParent])
            enemy.runAction(sequence)
            }
        }
    }
    
    func spawnEnemy(time: NSTimeInterval) {
        if time - latestSpawn > currentLevel.spawnPeriod {
            let randomIndex = Int(arc4random_uniform(UInt32(currentLevel.spawnLocations.count)))
            let spawnLocation = currentLevel.spawnLocations[randomIndex]
            var targetsArray = [Player]()
            for key in currentLevel.playerDict.allKeys {
                targetsArray.append(currentLevel.playerDict.objectForKey(key) as! Player)
            }
            let newEnemy = currentLevel.createEnemy(spawnLocation, targetsArray: targetsArray)
            currentLevel.worldNode.addChildNode(newEnemy)
            currentLevel.enemyArray.append(newEnemy)
            latestSpawn = time
        }
    }
}
