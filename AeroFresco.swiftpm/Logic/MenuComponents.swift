//
//  MenuComponents.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 15/02/26.
//

import SwiftUI

struct MenuPill: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 30)
            .frame(minWidth: 280)
            .background(
                Capsule()
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.6), radius: 15, x: 0, y: 8)
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyPillStyle())
    }
}

struct BouncyPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}
