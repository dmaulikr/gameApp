//
//  Level.swift
//  gameApp
//
//  Created by Liza on 2/3/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Level: SCNNode {
    var worldNode: SCNNode!
    var playerDict = NSMutableDictionary()
    var enemyArray = [Enemy]()
    var spawnLocations = [SCNVector3]()
    var spawnPeriod: NSTimeInterval!
    var soundtrackAudioSource: SCNAudioSource?
    var soundtrackAudioPlayer: SCNAudioPlayer?
    var enemyType: EnemyFactory.EnemyType!
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createEnemy(position: SCNVector3, targetsArray: [Player]) -> Enemy {
        var newEnemy: Enemy
        
        switch self.enemyType! {
        case .LambentMale:
            newEnemy = EnemyFactory.createLambentMale(position, targets: targetsArray, levelNode: self.worldNode)
        case .RobbieRabbit:
            newEnemy = EnemyFactory.createRobbieRabbit(position, targets: targetsArray, levelNode: self.worldNode)
        }
        return newEnemy
    }
}
