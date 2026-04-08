//
//  PencilKitView.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 09/02/26.
//

import SwiftUI
import PencilKit

struct PencilKitView: UIViewRepresentable {
    let canvasView: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.overrideUserInterfaceStyle = .light
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
}
