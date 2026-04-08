//
//  CameraService.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import AVFoundation
import CoreImage
import UIKit

protocol CameraServiceDelegate: AnyObject {
    nonisolated func cameraService(_ service: CameraService, didCaptureFrame pixelBuffer: CVPixelBuffer)
}

class CameraService: NSObject, @unchecked Sendable {
    weak var delegate: CameraServiceDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { DispatchQueue.main.async { self.setupCamera() } }
            }
        default: break
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
        
        let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)
        self.rotationCoordinator = coordinator
        
        rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: .new) { [weak self] _, _ in
            self?.updateRotation()
        }
        
        updateRotation()
        
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async { self.captureSession.startRunning() }
    }
    
    private func updateRotation() {
        guard let connection = videoOutput.connection(with: .video),
              let coordinator = rotationCoordinator else { return }
        
        let angle = coordinator.videoRotationAngleForHorizonLevelCapture
        
        if connection.videoRotationAngle != angle {
            connection.videoRotationAngle = angle
        }
        
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        delegate?.cameraService(self, didCaptureFrame: pixelBuffer)
    }
}
