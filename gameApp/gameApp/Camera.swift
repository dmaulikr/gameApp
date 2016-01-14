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

    var oldHorizontalRotation: SCNMatrix4?
    var oldVerticalRotation: SCNMatrix4?
    
    var horizontalRotation: SCNMatrix4?
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
    
    func cameraRotationValid(angle: CGFloat) -> Bool {
        var cameraAngle: CGFloat
        if self.rotation.x > 0 {
            cameraAngle = self.rotation.w
        } else {
            cameraAngle = -self.rotation.w
        }
        
        if cameraAngle + angle < CGFloat(M_PI_2) && cameraAngle + angle > CGFloat(-M_PI_2) {
            return true
        } else {
            return false
        }
    }
}
