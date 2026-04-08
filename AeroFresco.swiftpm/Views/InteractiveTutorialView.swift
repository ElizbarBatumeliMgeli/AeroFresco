//
//  InteractiveTutorialView.swift
//  AeroFresco
//
//  Created by Elizbar Kheladze on 08/04/26.
//

import SwiftUI

struct InteractiveTutorialView: View {
    let step: TutorialStep
    let isTransitioning: Bool
    let canvasSize: CGSize
    
    var body: some View {
        VStack(spacing: canvasSize.height * 0.02) {
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: canvasSize.height * 0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            VStack(spacing: 8) {
                Text(instructionText)
                    .font(.system(size: max(18, canvasSize.width * 0.025), weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .animation(.none, value: isTransitioning)
                    .fixedSize(horizontal: false, vertical: true)
                
                if isTransitioning {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: max(24, canvasSize.width * 0.035)))
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: max(24, canvasSize.width * 0.035)))
                        .opacity(0)
                }
            }
            .frame(height: canvasSize.height * 0.12)
        }
        .padding(canvasSize.width * 0.03)
        .frame(width: canvasSize.width * 0.45)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
    
    var imageName: String {
        switch step {
        case .drawSingle: return "draw_Single_Guide"
        case .stopSingle: return "stop_Single_Guide"
        case .drawDouble: return "draw_Double_Guide"
        case .pinchColor: return "pinch_guide"
        case .completed: return ""
        }
    }
    
    var instructionText: String {
        if isTransitioning { return "Perfect!" }
        switch step {
        case .drawSingle: return "Point your index finger to draw"
        case .stopSingle: return "Open your thumb to stop drawing"
        case .drawDouble: return "Use two fingers for bold lines"
        case .pinchColor: return "Pinch to cycle colors"
        case .completed: return "You're ready!"
        }
    }
}
