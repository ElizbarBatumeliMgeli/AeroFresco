//
//  GestureEngine.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import CoreGraphics
internal import Vision

class GestureEngine {
    private var gestureHistory: [UUID: [HandGesture]] = [:]
    private let historySize = 3
    
    func analyzeGesture(id: UUID, points: [VNHumanHandPoseObservation.JointName : CGPoint], isDominant: Bool, chirality: VNChirality) -> HandGesture {
        guard let wrist = points[.wrist],
              let thumbTip = points[.thumbTip],
              let indexTip = points[.indexTip], let indexMCP = points[.indexMCP],
              let middleTip = points[.middleTip], let middleMCP = points[.middleMCP],
              let ringTip = points[.ringTip], let ringMCP = points[.ringMCP],
              let littleTip = points[.littleTip], let littleMCP = points[.littleMCP] else { return .unknown }
        
        func isCurled(_ tip: CGPoint, _ mcp: CGPoint) -> Bool {
            let scale = hypot(middleMCP.x - wrist.x, middleMCP.y - wrist.y)
            let len = hypot(tip.x - mcp.x, tip.y - mcp.y)
            let tipToWristDist = hypot(tip.x - wrist.x, tip.y - wrist.y)
            let mcpToWristDist = hypot(mcp.x - wrist.x, mcp.y - wrist.y)
            
            return (len / scale) < 0.55 || (tipToWristDist / max(mcpToWristDist, 0.01)) < 1.2
        }
        
        let iCurl = isCurled(indexTip, indexMCP)
        let mCurl = isCurled(middleTip, middleMCP)
        let rCurl = isCurled(ringTip, ringMCP)
        let lCurl = isCurled(littleTip, littleMCP)
        
        if iCurl && mCurl && rCurl && lCurl {
            return stabilizeGesture(.fist, id: id)
        }
        
        if !isDominant {
            if !iCurl && !mCurl {
                return stabilizeGesture(.openPalm, id: id)
            }
        }
        
        if isDominant {
            guard let indexPIP = points[.indexPIP],
                  let indexDIP = points[.indexDIP],
                  let middlePIP = points[.middlePIP],
                  let middleDIP = points[.middleDIP],
                  let ringPIP = points[.ringPIP],
                  let ringDIP = points[.ringDIP],
                  let littlePIP = points[.littlePIP],
                  let littleDIP = points[.littleDIP] else { return .unknown }
            
            func isExtended(_ tip: CGPoint, _ dip: CGPoint, _ pip: CGPoint, _ mcp: CGPoint) -> Bool {
                let tipDist = hypot(tip.x - wrist.x, tip.y - wrist.y)
                let dipDist = hypot(dip.x - wrist.x, dip.y - wrist.y)
                let pipDist = hypot(pip.x - wrist.x, pip.y - wrist.y)
                
                return tipDist > (dipDist - 0.015) && dipDist > (pipDist - 0.015)
            }
            
            let iUp = isExtended(indexTip, indexDIP, indexPIP, indexMCP)
            let mUp = isExtended(middleTip, middleDIP, middlePIP, middleMCP)
            let rUp = isExtended(ringTip, ringDIP, ringPIP, ringMCP)
            let lUp = isExtended(littleTip, littleDIP, littlePIP, littleMCP)
            
            guard let thumbCMC = points[.thumbCMC] else { return .unknown }
            
            let scale = hypot(middleMCP.x - wrist.x, middleMCP.y - wrist.y)

            let thumbToLittleDist = hypot(thumbTip.x - littleTip.x, thumbTip.y - littleTip.y)
            let normalizedThumbLittleDist = thumbToLittleDist / scale
            let thumbLength = hypot(thumbTip.x - thumbCMC.x, thumbTip.y - thumbCMC.y)
            let thumbExtensionRatio = thumbLength / scale
            let isThumbExtended = thumbExtensionRatio > 0.45
            let isThumbFarFromLittle = normalizedThumbLittleDist > 0.80
            if isThumbExtended && isThumbFarFromLittle {
                let thumbIndexDist = hypot(thumbTip.x - indexTip.x, thumbTip.y - indexTip.y)
                let normalizedThumbIndexDist = thumbIndexDist / scale
                let isPinching = normalizedThumbIndexDist < 0.3
                
                if isPinching {
                    return stabilizeGesture(.pistolTrigger, id: id)
                } else {
                    return stabilizeGesture(.pistol, id: id)
                }
            }
            
            if iUp && mUp && !rUp && !lUp {
                return stabilizeGesture(.pointingTwo, id: id)
            }
            
            if iUp && !mUp && !rUp && !lUp {
                let detectedGesture: HandGesture = .pointing
                return stabilizeGesture(detectedGesture, id: id)
            }
        }
        
        let detectedGesture: HandGesture = .unknown
        return stabilizeGesture(detectedGesture, id: id)
    }
    
    private func stabilizeGesture(_ newGesture: HandGesture, id: UUID) -> HandGesture {
        var history = gestureHistory[id] ?? []
        history.append(newGesture)
        
        if history.count > historySize {
            history.removeFirst()
        }
        gestureHistory[id] = history
        
        if history.count >= 2 {
            let gestureCounts = Dictionary(grouping: history, by: { $0 }).mapValues { $0.count }
            if let mostCommon = gestureCounts.max(by: { $0.value < $1.value })?.key,
               gestureCounts[mostCommon]! >= 2 {
                return mostCommon
            }
        }
        
        return newGesture
    }
    
    func reset(id: UUID) {
        gestureHistory.removeValue(forKey: id)
    }
    
    func resetAll() {
        gestureHistory.removeAll()
    }
}
