//
//  HUD.swift
//  gameApp
//
//  Created by Liza Girsova on 10/11/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SpriteKit

class HUD: SKScene {

    var crosshair: SKShapeNode!
    var healthMeter: SKSpriteNode!
    var healthLabel: SKLabelNode!
    var ammoLabel: SKLabelNode!
    var deadLabel: SKLabelNode!
    var backgroundNode: SKSpriteNode!
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Draw crosshair
        self.crosshair = SKShapeNode(circleOfRadius: 4)
        //self.crosshair.strokeColor = SKColor.blackColor()
        self.crosshair.fillColor = SKColor.blackColor()
        self.crosshair.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.5)
        //self.crosshair.zPosition = 1.0
        
        self.healthLabel = SKLabelNode(fontNamed: "Avenir Next")
        self.healthLabel.name = "healthLabel"
        self.healthLabel.fontSize = 25
        self.healthLabel.fontColor = NSColor.whiteColor()
        self.healthLabel.text = "Health: 100"
        self.healthLabel.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.9)
        
        self.ammoLabel = SKLabelNode(fontNamed: "Avenir Next")
        self.ammoLabel.name = "ammoLabel"
        self.ammoLabel.fontSize = 25
        self.ammoLabel.fontColor = NSColor.whiteColor()
        self.ammoLabel.text = "8 | 36"
        self.ammoLabel.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.8)
        
        self.addChild(crosshair)
        self.addChild(self.healthLabel)
        self.addChild(self.ammoLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateSelf(infoDict: Dictionary<String, AnyObject>) {
        
    }
    
    func updateHealthLabel(newLabel: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.healthLabel.text = newLabel
        })
    }
    
    func updateAmmoLabel(newLabel: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ammoLabel.text = newLabel
        })
    }
    
    func setDeadView() {
        self.backgroundNode = SKSpriteNode(color: NSColor.blackColor(), size: CGSize(width: self.frame.width*2, height: self.frame.height*2))
        self.backgroundNode.position = CGPointMake(0, 0)
        self.backgroundNode.alpha = 0.27
        self.deadLabel = SKLabelNode(fontNamed: "Cracked")
        self.deadLabel.name = "deadLabel"
        self.deadLabel.fontSize = 100
        self.deadLabel.fontColor = NSColor.redColor()
        self.deadLabel.text = "You Are DEAD!"
        self.deadLabel.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.4)
        self.addChild(backgroundNode)
        backgroundNode.addChild(deadLabel)
    }
}
