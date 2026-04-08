//
//  HandGesture.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import Foundation

enum HandGesture: String {
    case openPalm = "Open"
    case pointing = "Draw (Thin)"
    case pointingTwo = "Draw (Bold)"
    case fist = "Fist"
    case pistol = "Stop Drawing"
    case pistolTrigger = "Pinch to Cycle Color"
    case unknown = "❓"
}

enum TutorialStep: Int, CaseIterable {
    case drawSingle
    case stopSingle
    case drawDouble
    case pinchColor
    case completed
}

