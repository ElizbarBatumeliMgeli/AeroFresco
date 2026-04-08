//
//  ToolButton.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 22/02/26.
//

import SwiftUI

struct ToolButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(isSelected ? Color.white : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .indigo : .white)
                .clipShape(Circle())
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(), value: isSelected)
        }
    }
}
