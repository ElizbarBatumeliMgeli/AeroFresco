//
//  HandStabilizer.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import Foundation
internal import Vision

class HandStabilizer {
    
    private var previousHands: [UUID : [VNHumanHandPoseObservation.JointName : CGPoint]] = [:]
    private var velocityBuffer: [UUID : [VNHumanHandPoseObservation.JointName : [CGPoint]]] = [:]
    private let motionThreshold: CGFloat = 0.003
    private let minSmoothingFactor: CGFloat = 0.7
    private let maxSmoothingFactor: CGFloat = 0.8
    private let velocityBufferSize = 3
    
    func filter(id: UUID, newPoints: [VNHumanHandPoseObservation.JointName : CGPoint]) -> [VNHumanHandPoseObservation.JointName : CGPoint] {
        var stabilizedPoints = newPoints
        
        if let oldPoints = previousHands[id] {
            var newStabilized: [VNHumanHandPoseObservation.JointName : CGPoint] = [:]
            
            for (joint, newPoint) in newPoints {
                if let oldPoint = oldPoints[joint] {
                    let distance = hypot(newPoint.x - oldPoint.x, newPoint.y - oldPoint.y)
                    
                    if distance < motionThreshold {
                        newStabilized[joint] = oldPoint
                    } else {
                        let normalizedDistance = min(distance / 0.1, 1.0)
                        let adaptiveSmoothingFactor = maxSmoothingFactor - (normalizedDistance * (maxSmoothingFactor - minSmoothingFactor))
                        let sx = oldPoint.x + (newPoint.x - oldPoint.x) * adaptiveSmoothingFactor
                        let sy = oldPoint.y + (newPoint.y - oldPoint.y) * adaptiveSmoothingFactor
                        var buffer = velocityBuffer[id]?[joint] ?? []
                        buffer.append(CGPoint(x: sx, y: sy))
                        
                        if buffer.count > velocityBufferSize {
                            buffer.removeFirst()
                        }
                        
                        if velocityBuffer[id] == nil {
                            velocityBuffer[id] = [:]
                        }
                        velocityBuffer[id]?[joint] = buffer
                        
                        if buffer.count >= 2 {
                            let avgX = buffer.map { $0.x }.reduce(0, +) / CGFloat(buffer.count)
                            let avgY = buffer.map { $0.y }.reduce(0, +) / CGFloat(buffer.count)
                            newStabilized[joint] = CGPoint(x: avgX, y: avgY)
                        } else {
                            newStabilized[joint] = CGPoint(x: sx, y: sy)
                        }
                    }
                } else {
                    newStabilized[joint] = newPoint
                }
            }
            stabilizedPoints = newStabilized
        }
        
        previousHands[id] = stabilizedPoints
        return stabilizedPoints
    }
    
    func reset(id: UUID) {
        previousHands.removeValue(forKey: id)
        velocityBuffer.removeValue(forKey: id)
    }

    func resetAll() {
        previousHands.removeAll()
        velocityBuffer.removeAll()
    }
}
