//
//  CanvasViewModel.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import SwiftUI
import Observation
internal import Vision
import PencilKit

@Observable
class CanvasViewModel: NSObject, CameraServiceDelegate, @unchecked Sendable {
    
    @ObservationIgnored private let cameraService = CameraService()
    @ObservationIgnored private let visionService = VisionService()
    @ObservationIgnored private let gestureEngine = GestureEngine()
    let pkCanvas: PKCanvasView
    var currentFrame: CGImage?
    var detectedHands: [HandInfo] = []
    var debugText: String = "Ready"
    var isDualHandMode: Bool = false
    var selectedToolType: PKInkingTool.InkType = .pen
    var selectedToolTypeLeft: PKInkingTool.InkType = .pen
    var selectedToolTypeRight: PKInkingTool.InkType = .pen
    var selectedColor: Color = .green
    var selectedColorLeft: Color = .red
    var selectedColorRight: Color = .blue
    var isEraserActive: Bool = false
    var isEraserActiveLeft: Bool = false
    var isEraserActiveRight: Bool = false
    
    var isTutorialActive: Bool = false
    var currentTutorialStep: TutorialStep = .drawSingle
    var isTutorialTransitioning: Bool = false
    
    @ObservationIgnored let baseWidth: CGFloat = 7.5
    @ObservationIgnored let boldWidth: CGFloat = 20.0
    
    var availableColors: [Color] = [.blue, .cyan, .green, .purple, .pink, .white]
    var availableColorsLeft: [Color] = [.red, .orange, .yellow, .brown, .gray, .black]
    var availableColorsRight: [Color] = [.blue, .cyan, .green, .purple, .pink, .white]
    @ObservationIgnored private var lastDrawPoint: CGPoint?
    @ObservationIgnored private var lastDrawPointLeft: CGPoint?
    @ObservationIgnored private var lastDrawPointRight: CGPoint?
    @ObservationIgnored private var isClutchEngaged = false
    @ObservationIgnored private var isPistolTriggerLock = false
    @ObservationIgnored private var isPistolTriggerLockLeft = false
    @ObservationIgnored private var isPistolTriggerLockRight = false
    @ObservationIgnored private var hand1ID: UUID?
    @ObservationIgnored private var hand2ID: UUID?
    @ObservationIgnored private var lastValidHandInfo: HandInfo?
    @ObservationIgnored private var lastValidHandInfoLeft: HandInfo?
    @ObservationIgnored private var lastValidHandInfoRight: HandInfo?
    @ObservationIgnored private var lastValidHandTimestamp: Date?
    @ObservationIgnored private var lastValidHandTimestampLeft: Date?
    @ObservationIgnored private var lastValidHandTimestampRight: Date?
    @ObservationIgnored private let detectionGracePeriod: TimeInterval = 0.15
    
    @MainActor
    override init() {
        self.pkCanvas = PKCanvasView()
        super.init()
        setupCanvas()
        cameraService.delegate = self
        
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedInteractiveTutorial")
        if !hasCompleted {
            self.isTutorialActive = true
            self.currentTutorialStep = .drawSingle
        }
    }
    
    @MainActor
    private func setupCanvas() {
        pkCanvas.drawingPolicy = .anyInput
        pkCanvas.backgroundColor = .clear
        pkCanvas.isOpaque = false
    }

    func setTool(_ type: PKInkingTool.InkType) {
        isEraserActive = false
        selectedToolType = type
    }
    
    func toggleEraser() {
        isEraserActive.toggle()
    }
    
    func setColor(_ color: Color) {
        selectedColor = color
        isEraserActive = false
    }
    
    @MainActor
    func clearCanvas() {
        pkCanvas.drawing = PKDrawing()
    }
    
    func cameraService(_ service: CameraService, didCaptureFrame pixelBuffer: CVPixelBuffer) {
        visionService.detectHands(in: pixelBuffer) { [weak self] rawHands in
            guard let self = self else { return }
            
            let enriched = rawHands.map { hand -> HandInfo in
                let gesture = self.gestureEngine.analyzeGesture(id: hand.id, points: hand.points, isDominant: true, chirality: hand.chirality)
                return HandInfo(id: hand.id, chirality: hand.chirality, points: hand.points, gesture: gesture, wristPos: hand.wristPos)
            }
            
            DispatchQueue.main.async {
                self.processLogic(hands: enriched)
            }
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            DispatchQueue.main.async { self.currentFrame = cgImage }
        }
    }
    
    @MainActor
    private func processLogic(hands: [HandInfo]) {
        if isDualHandMode {
            processDualHandMode(hands: hands)
        } else {
            processSingleHandMode(hands: hands)
        }
    }
    
    @MainActor
    private func checkTutorialProgress(gesture: HandGesture) {
        guard isTutorialActive, !isTutorialTransitioning else { return }
        
        var stepCompleted = false
        switch currentTutorialStep {
        case .drawSingle:
            stepCompleted = (gesture == .pointing)
        case .stopSingle:
            stepCompleted = (gesture == .pistol)
        case .drawDouble:
            stepCompleted = (gesture == .pointingTwo)
        case .pinchColor:
            stepCompleted = (gesture == .pistolTrigger)
        case .completed:
            break
        }
        
        if stepCompleted {
            isTutorialTransitioning = true
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.advanceTutorial()
            }
        }
    }
    
    @MainActor
    private func advanceTutorial() {
        let allSteps = TutorialStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentTutorialStep), currentIndex < allSteps.count - 1 {
            currentTutorialStep = allSteps[currentIndex + 1]
            if currentTutorialStep == .completed {
                isTutorialActive = false
                UserDefaults.standard.set(true, forKey: "hasCompletedInteractiveTutorial")
            }
        }
        isTutorialTransitioning = false
    }
    
    @MainActor
    private func processSingleHandMode(hands: [HandInfo]) {
        var dom: HandInfo?
        
        if let lastValid = lastValidHandInfo {
            dom = hands.first(where: { $0.id == lastValid.id })
        }
        
        let now = Date()
        if dom == nil,
           let lastValid = lastValidHandInfo,
           let lastTimestamp = lastValidHandTimestamp,
           now.timeIntervalSince(lastTimestamp) < detectionGracePeriod {
            dom = lastValid
        } else if dom == nil {
            dom = hands.first
        }
        
        if let d = dom, hands.contains(where: { $0.id == d.id }) {
            lastValidHandInfo = d
            lastValidHandTimestamp = now
        }
        
        if let d = dom {
            self.detectedHands = [d]
        } else {
            self.detectedHands = []
        }
        
        updateDebug(dom: dom, nonDom: nil)
        
        if let d = dom {
            checkTutorialProgress(gesture: d.gesture)
            
            if d.gesture == .pistol {
                if !isClutchEngaged { isClutchEngaged = true }
                lastDrawPoint = nil
                isPistolTriggerLock = false
                return
            }
            
            if d.gesture == .pistolTrigger {
                if !isClutchEngaged { isClutchEngaged = true }
                
                if !isPistolTriggerLock {
                    cycleColor()
                    isPistolTriggerLock = true
                }
                lastDrawPoint = nil
                return
            }
            
            if d.gesture != .pistol && d.gesture != .pistolTrigger {
                if isClutchEngaged { isClutchEngaged = false }
                isPistolTriggerLock = false
            }
            
            guard !isClutchEngaged else {
                lastDrawPoint = nil
                return
            }
            
            if isEraserActive {
                if d.gesture == .pointing || d.gesture == .pointingTwo {
                    guard let tip = d.points[.indexTip] else { return }
                    
                    let screenPoint = CGPoint(
                        x: tip.x * pkCanvas.bounds.width,
                        y: (1 - tip.y) * pkCanvas.bounds.height
                    )
                    
                    erase(at: screenPoint)
                }
                return
            }
            
            guard d.gesture == .pointing || d.gesture == .pointingTwo else {
                lastDrawPoint = nil
                return
            }
            
            let currentWidth = (d.gesture == .pointingTwo) ? boldWidth : baseWidth
            
            guard let tip = d.points[.indexTip] else {
                lastDrawPoint = nil
                return
            }
            
            let screenPoint = CGPoint(
                x: tip.x * pkCanvas.bounds.width,
                y: (1 - tip.y) * pkCanvas.bounds.height
            )
            
            draw(at: screenPoint, width: currentWidth, lastPoint: &lastDrawPoint, color: nil)
            
        } else {
            lastDrawPoint = nil
            isClutchEngaged = false
            isPistolTriggerLock = false
        }
    }
    
    @MainActor
        private func processDualHandMode(hands: [HandInfo]) {
            let now = Date()
            var h1: HandInfo? = nil
            var h2: HandInfo? = nil
            
            if let id1 = hand1ID {
                h1 = hands.first(where: { $0.id == id1 })
            }
            if let id2 = hand2ID {
                h2 = hands.first(where: { $0.id == id2 })
            }
            
            if h1 == nil,
               let lastValid = lastValidHandInfoLeft,
               let lastTimestamp = lastValidHandTimestampLeft {
                if now.timeIntervalSince(lastTimestamp) < detectionGracePeriod {
                    h1 = lastValid
                } else {
                    hand1ID = nil
                }
            }
            
            if h2 == nil,
               let lastValid = lastValidHandInfoRight,
               let lastTimestamp = lastValidHandTimestampRight {
                if now.timeIntervalSince(lastTimestamp) < detectionGracePeriod {
                    h2 = lastValid
                } else {
                    hand2ID = nil
                }
            }
            
            for hand in hands {
                if hand.id == hand1ID || hand.id == hand2ID { continue }
                
                if h1 == nil {
                    h1 = hand
                    hand1ID = hand.id
                } else if h2 == nil {
                    h2 = hand
                    hand2ID = hand.id
                }
            }
            
            if let validH1 = h1, hands.contains(where: { $0.id == validH1.id }) {
                lastValidHandInfoLeft = validH1
                lastValidHandTimestampLeft = now
            }
            
            if let validH2 = h2, hands.contains(where: { $0.id == validH2.id }) {
                lastValidHandInfoRight = validH2
                lastValidHandTimestampRight = now
            }
            
            var displayHands: [HandInfo] = []
            if var validH1 = h1 {
                validH1.dualModeLabel = "H1"
                displayHands.append(validH1)
                h1 = validH1
            }
            if var validH2 = h2 {
                validH2.dualModeLabel = "H2"
                displayHands.append(validH2)
                h2 = validH2
            }
            
            self.detectedHands = displayHands
            
            updateDebug(dom: h1, nonDom: h2)
            
            if let left = h1 {
                checkTutorialProgress(gesture: left.gesture)
                
                if left.gesture == .pistolTrigger {
                    if !isPistolTriggerLockLeft {
                        cycleColorLeft()
                        isPistolTriggerLockLeft = true
                    }
                    lastDrawPointLeft = nil
                } else {
                    isPistolTriggerLockLeft = false
                    processDrawingHand(left, lastPoint: &lastDrawPointLeft, color: selectedColorLeft, isErasing: isEraserActiveLeft, isH2: false)
                }
            } else {
                lastDrawPointLeft = nil
                isPistolTriggerLockLeft = false
            }
            
            if let right = h2 {
                checkTutorialProgress(gesture: right.gesture)
                
                if right.gesture == .pistolTrigger {
                    if !isPistolTriggerLockRight {
                        cycleColorRight()
                        isPistolTriggerLockRight = true
                    }
                    lastDrawPointRight = nil
                } else {
                    isPistolTriggerLockRight = false
                    processDrawingHand(right, lastPoint: &lastDrawPointRight, color: selectedColorRight, isErasing: isEraserActiveRight, isH2: true)
                }
            } else {
                lastDrawPointRight = nil
                isPistolTriggerLockRight = false
            }
        }
    
    @MainActor
    private func processDrawingHand(_ hand: HandInfo, lastPoint: inout CGPoint?, color: Color, isErasing: Bool = false, isH2: Bool = false) {
        if isErasing {
            if hand.gesture == .pointing || hand.gesture == .pointingTwo {
                guard let tip = hand.points[.indexTip] else { return }
                
                let screenPoint = CGPoint(
                    x: tip.x * pkCanvas.bounds.width,
                    y: (1 - tip.y) * pkCanvas.bounds.height
                )
                
                erase(at: screenPoint)
            }
            return
        }
        
        guard hand.gesture == .pointing || hand.gesture == .pointingTwo else {
            lastPoint = nil
            return
        }
        
        let currentWidth = (hand.gesture == .pointingTwo) ? boldWidth : baseWidth
        
        guard let tip = hand.points[.indexTip] else {
            lastPoint = nil
            return
        }
        
        let screenPoint = CGPoint(
            x: tip.x * pkCanvas.bounds.width,
            y: (1 - tip.y) * pkCanvas.bounds.height
        )
        
        let toolType = isDualHandMode ? (isH2 ? selectedToolTypeRight : selectedToolTypeLeft) : selectedToolType
        
        draw(at: screenPoint, width: currentWidth, lastPoint: &lastPoint, color: color, toolType: toolType)
    }
    
    @MainActor
    private func draw(at point: CGPoint, width: CGFloat, lastPoint: inout CGPoint?, color: Color? = nil, toolType: PKInkingTool.InkType? = nil) {
        if lastPoint == nil {
            lastPoint = point
            return
        }
        
        let start = lastPoint!
        
        let drawColor = color ?? selectedColor
        let drawToolType = toolType ?? selectedToolType
        let uiColor = drawColor.toUIColor()
        let ink = PKInk(drawToolType, color: uiColor)
        
        let path = PKStrokePath(controlPoints: [
            PKStrokePoint(location: start, timeOffset: 0, size: CGSize(width: width, height: width), opacity: 1, force: 1, azimuth: 0, altitude: 0),
            PKStrokePoint(location: point, timeOffset: 0.016, size: CGSize(width: width, height: width), opacity: 1, force: 1, azimuth: 0, altitude: 0)
        ], creationDate: Date())
        
        let stroke = PKStroke(ink: ink, path: path)
        pkCanvas.drawing.strokes.append(stroke)
        
        lastPoint = point
    }
    
    @MainActor
    private func erase(at point: CGPoint) {
        let eraserSize: CGFloat = 30.0
        let eraserRect = CGRect(
            x: point.x - eraserSize / 2,
            y: point.y - eraserSize / 2,
            width: eraserSize,
            height: eraserSize
        )
        
        var drawing = pkCanvas.drawing
        var strokesToKeep: [PKStroke] = []
        
        for stroke in drawing.strokes {
            var shouldKeep = true
            for point in stroke.path {
                if eraserRect.contains(point.location) {
                    shouldKeep = false
                    break
                }
            }
            if shouldKeep {
                strokesToKeep.append(stroke)
            }
        }
        
        drawing.strokes = strokesToKeep
        pkCanvas.drawing = drawing
    }
    
    func cycleColor() {
        if let i = availableColors.firstIndex(of: selectedColor) {
            selectedColor = availableColors[(i + 1) % availableColors.count]
        }
    }
    
    func cycleColorLeft() {
        if let i = availableColorsLeft.firstIndex(of: selectedColorLeft) {
            selectedColorLeft = availableColorsLeft[(i + 1) % availableColorsLeft.count]
        }
    }
    
    func cycleColorRight() {
        if let i = availableColorsRight.firstIndex(of: selectedColorRight) {
            selectedColorRight = availableColorsRight[(i + 1) % availableColorsRight.count]
        }
    }
    
    private func updateDebug(dom: HandInfo?, nonDom: HandInfo?) {
        debugText = "Dom: \(dom?.gesture.rawValue ?? "-") | Non: \(nonDom?.gesture.rawValue ?? "-")"
    }
}

extension Color {
    func toUIColor() -> UIColor {
        return UIColor(self)
    }
}
