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

    var oldVerticalRotation: SCNMatrix4?
    var verticalRotation: SCNMatrix4?
    
    override init() {
        super.init()
        
        let scncamera = SCNCamera()
        scncamera.zFar = 1_000
        self.camera = scncamera
        
        verticalRotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        oldVerticalRotation = self.transform
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func calculateTransform() {
        
    }
    
    func updateTransform() {
        
    }
}
