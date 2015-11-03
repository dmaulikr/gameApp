//
//  VectorMath.swift
//  gameApp
//
//  Created by Liza Girsova on 11/2/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import SceneKit

class VectorMath: NSObject {

    @nonobjc static func getVectorMagnitude(vector3: SCNVector3) -> CGFloat {
        return CGFloat(sqrtf(Float(vector3.x*vector3.x)+Float(vector3.y*vector3.y)+Float(vector3.z*vector3.z)))
    }
    
    static func getVectorMagnitude(vector2: CGVector) -> CGFloat {
        return CGFloat(sqrtf(Float(vector2.dx*vector2.dx)+Float(vector2.dy*vector2.dy)))
    }
    
    @nonobjc static func getNormalizedVector(vector3: SCNVector3) -> SCNVector3 {
        let vectorMagnitude = getVectorMagnitude(vector3)
        return SCNVector3Make(vector3.x/CGFloat(vectorMagnitude), vector3.y/CGFloat(vectorMagnitude), vector3.z/CGFloat(vectorMagnitude))
    }
    
    static func getNormalizedVector(vector2: CGVector) -> CGVector {
        let vectorMagnitude = getVectorMagnitude(vector2)
        return CGVectorMake(vector2.dx/CGFloat(vectorMagnitude), vector2.dy/CGFloat(vectorMagnitude))
    }
    
    static func multiplyVectorByScalar(left: SCNVector3, right: CGFloat) -> SCNVector3 {
        return SCNVector3Make(left.x * right, left.y * right, left.z * right)
    }
    
    static func multiplyVectorByVector(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x*right.x, left.y*right.y, left.z*right.z)
    }
    
    static func addVectorToVector(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x+right.x, left.y+right.y, left.z+right.z)
    }

    static func getDirectionVector(startPoint: SCNVector3, finishPoint: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: finishPoint.x - startPoint.x, y: finishPoint.y - startPoint.y, z: finishPoint.z - startPoint.z)
    }
    
    static func dotProduct(left: SCNVector3, right: SCNVector3) -> CGFloat {
        return left.x*right.x+left.y*right.y+left.z*right.z
    }
    
}
