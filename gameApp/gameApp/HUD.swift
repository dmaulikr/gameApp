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
    var healthMeter: SKShapeNode!
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Draw crosshair
        self.crosshair = SKShapeNode(circleOfRadius: 3)
        self.crosshair.strokeColor = SKColor.blackColor()
        self.crosshair.fillColor = SKColor.blackColor()
        self.crosshair.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.5)
        self.addChild(crosshair!)
        
        // Draw health meter
        self.healthMeter = SKShapeNode(rectOfSize: CGSizeMake(100, 10))
        self.healthMeter.strokeColor = SKColor.blackColor()
        self.healthMeter.fillColor = SKColor.redColor()
        self.healthMeter.position = CGPointMake(self.frame.width*0.95, self.frame.height*0.95)
        self.addChild(healthMeter)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
