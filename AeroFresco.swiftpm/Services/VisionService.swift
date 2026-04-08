//
//  VisionService.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

internal import Vision
import UIKit

class VisionService {
    private let stabilizer = HandStabilizer()
    private var trackedHands: [UUID: TrackedHand] = [:]
    private let maxTrackingDistance: CGFloat = 0.15
    private let trackingLostTimeout: TimeInterval = 0.3
    
    private struct TrackedHand {
        let id: UUID
        let chirality: VNChirality
        let lastPosition: CGPoint
        let lastSeen: Date
        let confidenceScore: Int
        let chiralityConfidence: Int
    }
    
    func detectHands(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up, completion: @escaping ([HandInfo]) -> Void) {
        
        let request = VNDetectHumanHandPoseRequest { request, error in
            guard let observations = request.results as? [VNHumanHandPoseObservation], !observations.isEmpty else {
                completion([])
                return
            }
            
            var processedHands: [HandInfo] = []
            let now = Date()
            
            self.trackedHands = self.trackedHands.filter { id, hand in
                let isStillPresent = now.timeIntervalSince(hand.lastSeen) < self.trackingLostTimeout
                if !isStillPresent {
                    self.stabilizer.reset(id: hand.id)
                }
                return isStillPresent
            }
            
            var matched: Set<UUID> = []
            var unmatchedObservations: [(observation: VNHumanHandPoseObservation, wrist: CGPoint, points: [VNHumanHandPoseObservation.JointName: CGPoint])] = []
            
            for observation in observations {
                guard let points = try? observation.recognizedPoints(.all).compactMapValues({ point in
                    point.confidence > 0.3 ? CGPoint(x: point.location.x, y: point.location.y) : nil
                }) else { continue }
                
                guard let wrist = points[.wrist] else { continue }
                
                var bestMatch: (id: UUID, distance: CGFloat)?
                
                for (id, tracked) in self.trackedHands where !matched.contains(id) {
                    let distance = hypot(wrist.x - tracked.lastPosition.x, wrist.y - tracked.lastPosition.y)
                    
                    if distance < self.maxTrackingDistance {
                        if bestMatch == nil || distance < bestMatch!.distance {
                            bestMatch = (id, distance)
                        }
                    }
                }
                
                if let match = bestMatch {
                    let tracked = self.trackedHands[match.id]!
                    let chirality: VNChirality
                    let chiralityConf: Int
                    if tracked.chiralityConfidence >= 5 {
                        chirality = tracked.chirality
                        chiralityConf = tracked.chiralityConfidence
                    } else {
                        let validated = self.validateChirality(
                            reportedChirality: observation.chirality,
                            points: points,
                            existingChirality: tracked.chirality,
                            allTrackedHands: self.trackedHands,
                            currentID: match.id
                        )
                        chirality = validated
                        
                        if validated == tracked.chirality {
                            chiralityConf = min(tracked.chiralityConfidence + 1, 10)
                        } else {
                            chiralityConf = 1
                        }
                    }
                    
                    let confidence = min(tracked.confidenceScore + 1, 10)
                    matched.insert(match.id)
                    
                    self.trackedHands[match.id] = TrackedHand(
                        id: match.id,
                        chirality: chirality,
                        lastPosition: wrist,
                        lastSeen: now,
                        confidenceScore: confidence,
                        chiralityConfidence: chiralityConf
                    )
                    
                    let smoothPoints = self.stabilizer.filter(id: match.id, newPoints: points)
                    processedHands.append(HandInfo(id: match.id, chirality: chirality, points: smoothPoints, gesture: .unknown, wristPos: wrist))
                } else {
                    unmatchedObservations.append((observation, wrist, points))
                }
            }
            
            for (observation, wrist, points) in unmatchedObservations {
                let handID = UUID()
                
                let chirality = self.determineChiralityForNewHand(
                    observation: observation,
                    points: points,
                    wristPos: wrist,
                    existingHands: self.trackedHands
                )
                
                self.trackedHands[handID] = TrackedHand(
                    id: handID,
                    chirality: chirality,
                    lastPosition: wrist,
                    lastSeen: now,
                    confidenceScore: 1,
                    chiralityConfidence: 1
                )
                
                let smoothPoints = self.stabilizer.filter(id: handID, newPoints: points)
                processedHands.append(HandInfo(id: handID, chirality: chirality, points: smoothPoints, gesture: .unknown, wristPos: wrist))
            }
            
            completion(processedHands)
        }
        
        request.maximumHandCount = 2
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation).perform([request])
    }
    
    private func determineChiralityForNewHand(
        observation: VNHumanHandPoseObservation,
        points: [VNHumanHandPoseObservation.JointName: CGPoint],
        wristPos: CGPoint,
        existingHands: [UUID: TrackedHand]
    ) -> VNChirality {
        
        let reportedChirality = observation.chirality
        let anatomicalChirality = self.getAnatomicalChirality(points: points)
        let spatialChirality = self.getSpatialChirality(wristPos: wristPos, existingHands: existingHands)
        var votes: [VNChirality: Int] = [.left: 0, .right: 0]
        votes[reportedChirality, default: 0] += 2
        
        if let anatomical = anatomicalChirality {
            votes[anatomical, default: 0] += 2
        }
        
        if let spatial = spatialChirality {
            votes[spatial, default: 0] += 1
        }
        
        return votes[.left]! > votes[.right]! ? .left : .right
    }
    
    private func validateChirality(
        reportedChirality: VNChirality,
        points: [VNHumanHandPoseObservation.JointName: CGPoint],
        existingChirality: VNChirality,
        allTrackedHands: [UUID: TrackedHand],
        currentID: UUID
    ) -> VNChirality {
        
        let anatomicalChirality = self.getAnatomicalChirality(points: points)
        
        if let anatomical = anatomicalChirality, anatomical != existingChirality {
            let otherChirality: VNChirality = existingChirality == .left ? .right : .left
            let hasConfidentOtherHand = allTrackedHands.values.contains {
                $0.id != currentID && $0.chirality == otherChirality && $0.chiralityConfidence >= 5
            }
            
            if !hasConfidentOtherHand {
                return anatomical
            }
        }
        
        return existingChirality
    }
    
    private func getAnatomicalChirality(points: [VNHumanHandPoseObservation.JointName: CGPoint]) -> VNChirality? {
        guard let thumbMCP = points[.thumbMP],
              let indexMCP = points[.indexMCP] else {
            return nil
        }
        
        let thumbOffset = thumbMCP.x - indexMCP.x
        let confidenceThreshold: CGFloat = 0.02
        
        if thumbOffset > confidenceThreshold {
            return .left
        } else if thumbOffset < -confidenceThreshold {
            return .right
        } else {
            return nil
        }
    }
    
    private func getSpatialChirality(wristPos: CGPoint, existingHands: [UUID: TrackedHand]) -> VNChirality? {
        if existingHands.count == 1, let existingHand = existingHands.values.first {
            if wristPos.x < existingHand.lastPosition.x {
                return existingHand.chirality == .right ? .left : nil
            } else if wristPos.x > existingHand.lastPosition.x {
                return existingHand.chirality == .left ? .right : nil
            }
        }
        
        if wristPos.x < 0.4 {
            return .left
        } else if wristPos.x > 0.6 {
            return .right
        } else {
            return nil
        }
    }
}
