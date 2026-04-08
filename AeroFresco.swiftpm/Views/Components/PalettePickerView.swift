//
//  PalettePickerView.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 22/02/26.
//

import SwiftUI

struct PalettePickerView: View {
    var viewModel: CanvasViewModel
    var isRightHand: Bool
    let onPaletteSelected: (ColorPalette) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ColorPalette.palettes) { palette in
                        Button(action: {
                            onPaletteSelected(palette)
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(palette.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 8) {
                                    ForEach(palette.colors.indices, id: \.self) { index in
                                        Circle()
                                            .fill(palette.colors[index])
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Color Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
