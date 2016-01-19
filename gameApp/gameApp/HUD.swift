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
    var crosshairLeft: SKSpriteNode!
    var crosshairRight: SKSpriteNode!
    var crosshairTop: SKSpriteNode!
    var crosshairBottom: SKSpriteNode!
    
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
        
        self.healthLabel = SKLabelNode(fontNamed: "San Francisco")
        self.healthLabel.name = "healthLabel"
        self.healthLabel.fontSize = 25
        self.healthLabel.fontColor = NSColor.whiteColor()
        self.healthLabel.text = "Health: 100"
        self.healthLabel.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.9)
        
        self.ammoLabel = SKLabelNode(fontNamed: "San Francisco")
        self.ammoLabel.name = "ammoLabel"
        self.ammoLabel.fontSize = 25
        self.ammoLabel.fontColor = NSColor.whiteColor()
        self.ammoLabel.text = "8 | 36"
        self.ammoLabel.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.8)
        
        self.crosshairLeft = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairLeft.position = CGPointMake(self.frame.width*0.495, self.frame.height*0.5)
        
        self.crosshairRight = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairRight.position = CGPointMake(self.frame.width*0.505, self.frame.height*0.5)
        
        self.crosshairTop = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairTop.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.505)

        self.crosshairBottom = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairBottom.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.495)
        
        self.addChild(crosshair)
        self.addChild(self.healthLabel)
        self.addChild(self.ammoLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
}
