//
//  HandOverlayView.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import SwiftUI
internal import Vision

enum VisualizationMode {
    case full
    case dotsOnly
    case hidden
}

struct HandOverlayView: View {
    var allHands: [HandInfo]
    var visualizationMode: VisualizationMode = .full
    var isDualMode: Bool = false
    let skeletonConnections: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
        (.wrist, .thumbCMC), (.thumbCMC, .thumbMP), (.thumbMP, .thumbIP), (.thumbIP, .thumbTip),
        (.wrist, .indexMCP), (.indexMCP, .indexPIP), (.indexPIP, .indexDIP), (.indexDIP, .indexTip),
        (.wrist, .middleMCP), (.middleMCP, .middlePIP), (.middlePIP, .middleDIP), (.middleDIP, .middleTip),
        (.wrist, .ringMCP), (.ringMCP, .ringPIP), (.ringPIP, .ringDIP), (.ringDIP, .ringTip),
        (.wrist, .littleMCP), (.littleMCP, .littlePIP), (.littlePIP, .littleDIP), (.littleDIP, .littleTip)
    ]
    let tips: [VNHumanHandPoseObservation.JointName] = [.thumbTip, .indexTip, .middleTip, .ringTip, .littleTip]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                if visualizationMode != .hidden {
                    ForEach(allHands, id: \.id) { hand in
                        let points = hand.points
                        if visualizationMode == .full {
                            Path { path in
                                for (startJoint, endJoint) in skeletonConnections {
                                    if let startPoint = points[startJoint], let endPoint = points[endJoint] {
                                        let start = convertPoint(startPoint, in: geometry.size)
                                        let end = convertPoint(endPoint, in: geometry.size)
                                        path.move(to: start)
                                        path.addLine(to: end)
                                    }
                                }
                            }
                            .stroke(!isDualMode ? Color.green : (hand.dualModeLabel == "H1" ? Color.blue : Color.green), lineWidth: 3)
                        }
                        ForEach(tips, id: \.self) { joint in
                            if let point = points[joint] {
                                let screenPoint = convertPoint(point, in: geometry.size)
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 8, height: 8)
                                    .position(screenPoint)
                            }
                        }
            
                        if isDualMode {
                            if let wrist = points[.wrist] {
                                let wristScreenPoint = convertPoint(wrist, in: geometry.size)
                                let labelText = hand.dualModeLabel ?? "H"
                                let bgColor = labelText == "H1" ? Color.blue : Color.green
                                
                                Text(labelText)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(bgColor)
                                    )
                                    .position(wristScreenPoint)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func convertPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        return CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    }
}
