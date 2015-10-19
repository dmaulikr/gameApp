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
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        print("initialized scene")
        self.crosshair = SKShapeNode(circleOfRadius: 3)
        self.crosshair.strokeColor = SKColor.blackColor()
        self.crosshair.fillColor = SKColor.blackColor()
        self.crosshair.position = CGPointMake(self.frame.width*0.5, self.frame.height*0.5)
        self.addChild(crosshair!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
