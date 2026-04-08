//
//  CGPoint+Extensions.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import CoreGraphics


extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    

    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    

    func normalized() -> CGPoint {
        let len = length()
        return len > 0 ? CGPoint(x: x/len, y: y/len) : .zero
    }
    

    static func dot(_ v1: CGPoint, _ v2: CGPoint) -> CGFloat {
        return v1.x * v2.x + v1.y * v2.y
    }
}
