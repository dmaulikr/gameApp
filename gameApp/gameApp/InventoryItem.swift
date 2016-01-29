//
//  InventoryItem.swift
//  gameApp
//
//  Created by Liza on 1/21/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class InventoryItem: SCNNode {
    
    enum BoostType {
        case Health
        case Ammo
    }
    
    var boostType: BoostType?
    var boostAmount: Int?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
