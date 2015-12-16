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
        
        
//        // Draw health meter
//        self.healthMeter = SKShapeNode(rectOfSize: CGSizeMake(175, 10))
//        //self.healthMeter.strokeColor = SKColor.blackColor()
//        self.healthMeter.fillColor = SKColor.redColor()
//        self.healthMeter.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.95)
//        //self.healthMeter.zPosition = 2.0
        
        //self.healthMeter = SKSpriteNode(color: NSColor.redColor(), size: CGSizeMake(175, 10))
        //self.healthMeter.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.95)
        
        self.healthLabel = SKLabelNode(fontNamed: "San Francisco")
        self.healthLabel.fontSize = 25
        self.healthLabel.fontColor = NSColor.whiteColor()
        self.healthLabel.text = "Health: 100"
        self.healthLabel.position = CGPointMake(self.frame.width*0.9, self.frame.height*0.95)
        
        self.crosshairLeft = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairLeft.position = CGPointMake(self.frame.width*0.495, self.frame.height*0.5)
        
        self.crosshairRight = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairRight.position = CGPointMake(self.frame.width*0.505, self.frame.height*0.5)
        
        self.crosshairTop = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairTop.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.505)

        self.crosshairBottom = SKSpriteNode(color: NSColor.blackColor(), size: CGSizeMake(2, 4))
        self.crosshairBottom.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.495)
        
        //self.addChild(healthMeter)
        self.addChild(crosshair)
        self.addChild(self.healthLabel)
//        self.addChild(crosshairLeft)
//        self.addChild(crosshairRight)
//        self.addChild(crosshairTop)
//        self.addChild(crosshairBottom)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHealth:", name: Constants.Notifications.updateHealth, object: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateHealth(notification: NSNotification) {
        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
        let newHealth = userInfo["newHealth"]
        let healthString = String(newHealth!)
        self.healthLabel.text = "Health: \(healthString)"
    }
}
