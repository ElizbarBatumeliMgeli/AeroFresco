//
//  HandTracking.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 15/02/26.
//

import CoreGraphics
internal import Vision

struct HandInfo {
    let id: UUID
    let chirality: VNChirality
    let points: [VNHumanHandPoseObservation.JointName : CGPoint]
    let gesture: HandGesture
    let wristPos: CGPoint
    var dualModeLabel: String? = nil
}
