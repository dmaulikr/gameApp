//
//  Weapon.swift
//  gameApp
//
//  Created by Liza Girsova on 10/20/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Weapon: SCNNode {
    
    var baseDamage: CGFloat?
    var ammoLoaded: CGFloat?
    var ammoCarried: CGFloat?
    var attackInterval: NSTimeInterval?
    var reloadTime: NSTimeInterval?
    var type: WeaponType?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
