//
//  FloatingToolbar.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 05/02/26.
//

import SwiftUI
import PencilKit

struct FloatingToolbar: View {
    var viewModel: CanvasViewModel
    var isRightHand: Bool = false
    
    @State private var showPaletteSheet = false
    @State private var customColors: [Color]? = nil
    @State private var customColorsLeft: [Color]? = nil
    @State private var customColorsRight: [Color]? = nil
    let defaultColors: [Color] = [.blue, .cyan, .green, .purple, .pink, .white]
    let defaultColorsLeft: [Color] = [.red, .orange, .yellow, .brown, .gray, .black]
    let defaultColorsRight: [Color] = [.blue, .cyan, .green, .purple, .pink, .white]
    
    var body: some View {
        @Bindable var vm = viewModel
        
        GeometryReader { geo in
            let idealHeight: CGFloat = currentEraserActive ? 350 : 690
            let scaleFactor = min(1.0, geo.size.height / idealHeight)
            
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    ToolButton(icon: "pencil.tip", isSelected: !currentEraserActive && currentToolType == .pen) {
                        setTool(.pen)
                    }
                    ToolButton(icon: "highlighter", isSelected: !currentEraserActive && currentToolType == .marker) {
                        setTool(.marker)
                    }
                    ToolButton(icon: "pencil.line", isSelected: !currentEraserActive && currentToolType == .pencil) {
                        setTool(.pencil)
                    }
                    
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 30, height: 1)
                    
                    ToolButton(icon: "eraser.fill", isSelected: currentEraserActive) {
                        toggleEraser()
                    }
                }
                
                if !currentEraserActive {
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 30, height: 1)
                    
                    VStack(spacing: 12) {
                        ForEach(currentColors, id: \.self) { color in
                            Button(action: {
                                if vm.isDualHandMode {
                                    if isRightHand {
                                        vm.selectedColorRight = color
                                    } else {
                                        vm.selectedColorLeft = color
                                    }
                                } else {
                                    vm.setColor(color)
                                }
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: isColorSelected(color) ? 3 : 0)
                                            .shadow(radius: 2)
                                    )
                            }
                        }
                    }
                    
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 30, height: 1)
                    
                    Button(action: { showPaletteSheet = true }) {
                        Image(systemName: "paintpalette.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(colors: [.purple, .pink, .orange],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                    }
                }
                if viewModel.isDualHandMode {
                    Text(isRightHand ? "H2" : "H1")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                }
            }
            .padding(.vertical, 20)
            .frame(width: 64)
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            .shadow(radius: 10)
            .scaleEffect(scaleFactor)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(width: 64)
        .sheet(isPresented: $showPaletteSheet) {
            PalettePickerView(
                viewModel: viewModel,
                isRightHand: isRightHand,
                onPaletteSelected: { palette in
                    applyPalette(palette)
                    showPaletteSheet = false
                }
            )
        }
    }
    
    var currentColors: [Color] {
        if viewModel.isDualHandMode {
            if isRightHand {
                return customColorsRight ?? defaultColorsRight
            } else {
                return customColorsLeft ?? defaultColorsLeft
            }
        } else {
            return customColors ?? defaultColors
        }
    }
    
    var currentToolType: PKInkingTool.InkType {
        if viewModel.isDualHandMode {
            return isRightHand ? viewModel.selectedToolTypeRight : viewModel.selectedToolTypeLeft
        } else {
            return viewModel.selectedToolType
        }
    }
    
    var currentEraserActive: Bool {
        if viewModel.isDualHandMode {
            return isRightHand ? viewModel.isEraserActiveRight : viewModel.isEraserActiveLeft
        } else {
            return viewModel.isEraserActive
        }
    }
    func toggleEraser() {
        if viewModel.isDualHandMode {
            if isRightHand {
                viewModel.isEraserActiveRight.toggle()
            } else {
                viewModel.isEraserActiveLeft.toggle()
            }
        } else {
            viewModel.toggleEraser()
        }
    }
    
    func setTool(_ type: PKInkingTool.InkType) {
        if viewModel.isDualHandMode {
            if isRightHand {
                viewModel.selectedToolTypeRight = type
                viewModel.isEraserActiveRight = false
            } else {
                viewModel.selectedToolTypeLeft = type
                viewModel.isEraserActiveLeft = false
            }
        } else {
            viewModel.setTool(type)
        }
    }
    
    func isColorSelected(_ color: Color) -> Bool {
        if viewModel.isDualHandMode {
            return isRightHand ? viewModel.selectedColorRight == color : viewModel.selectedColorLeft == color
        } else {
            return viewModel.selectedColor == color
        }
    }
    
    func applyPalette(_ palette: ColorPalette) {
        if viewModel.isDualHandMode {
            if isRightHand {
                customColorsRight = palette.colors
                viewModel.availableColorsRight = palette.colors
                viewModel.selectedColorRight = palette.colors.first ?? .blue
            } else {
                customColorsLeft = palette.colors
                viewModel.availableColorsLeft = palette.colors
                viewModel.selectedColorLeft = palette.colors.first ?? .red
            }
        } else {
            customColors = palette.colors
            viewModel.availableColors = palette.colors
            viewModel.setColor(palette.colors.first ?? .blue)
        }
    }
}
