//
//  Camera.swift
//  gameApp
//
//  Created by Liza Girsova on 10/11/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class Camera: SCNNode {

    override init() {
        super.init()
        
        let scncamera = SCNCamera()
        scncamera.zFar = 1_000
        self.camera = scncamera
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
