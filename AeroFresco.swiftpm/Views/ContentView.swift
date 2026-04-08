//
//  ContentView.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 04/02/26.
//

import SwiftUI

struct ContentView: View {
    @Binding var path: NavigationPath
    let isDualMode: Bool
    @State private var viewModel = CanvasViewModel()
    @State private var backgroundMode: BackgroundMode = .white
    @State private var visualizationMode: VisualizationMode = .full
    @State private var showSettings = false
    
    enum BackgroundMode {
        case camera, black, white
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button(action: { path = NavigationPath() }) {
                            HStack(spacing: 6) {
                                Text("Exit")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.red.opacity(0.85))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                        }
                        
                        Button(action: { viewModel.clearCanvas() }) {
                            HStack(spacing: 6) {
                                Text("Clear")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.indigo)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.85))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.indigo)
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.9))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                
                HStack(spacing: 20) {
                    if isDualMode {
                        FloatingToolbar(viewModel: viewModel, isRightHand: false)
                    } else {
                        FloatingToolbar(viewModel: viewModel, isRightHand: false)
                    }
                    
                    GeometryReader { canvasGeo in
                        ZStack {
                            switch backgroundMode {
                            case .camera:
                                Color.black
                                if let frame = viewModel.currentFrame {
                                    Image(decorative: frame, scale: 1.0)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: canvasGeo.size.width, height: canvasGeo.size.height)
                                        .clipped()
                                }
                            case .black:
                                Color.black
                                    .frame(width: canvasGeo.size.width, height: canvasGeo.size.height)
                            case .white:
                                Color.white
                                    .frame(width: canvasGeo.size.width, height: canvasGeo.size.height)
                            }
                            
                            PencilKitView(canvasView: viewModel.pkCanvas)
                            
                            HandOverlayView(allHands: viewModel.detectedHands, visualizationMode: visualizationMode, isDualMode: isDualMode)
                            
                            if viewModel.isTutorialActive {
                                VStack {
                                    InteractiveTutorialView(
                                        step: viewModel.currentTutorialStep,
                                        isTransitioning: viewModel.isTutorialTransitioning,
                                        canvasSize: canvasGeo.size
                                    )
                                    .padding(.top, 32)
                                    
                                    Spacer()
                                }
                                .animation(.spring(), value: viewModel.currentTutorialStep)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white, lineWidth: 8)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    
                    if isDualMode {
                        FloatingToolbar(viewModel: viewModel, isRightHand: true)
                    }
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            }
            .background {
                ZStack {
                    LinearGradient(colors: [Color.indigo, Color.purple.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    Circle().fill(.white.opacity(0.05)).frame(width: 600).offset(x: -400, y: -300)
                }
            }
            
            if showSettings {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showSettings = false
                        }
                    }

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Text("Hand Visualization")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                            
                            MenuButton(
                                title: "Full",
                                isSelected: visualizationMode == .full
                            ) {
                                withAnimation {
                                    visualizationMode = .full
                                }
                            }
                            
                            MenuButton(
                                title: "Dots Only",
                                isSelected: visualizationMode == .dotsOnly
                            ) {
                                withAnimation {
                                    visualizationMode = .dotsOnly
                                }
                            }
                            
                            MenuButton(
                                title: "Hidden",
                                isSelected: visualizationMode == .hidden
                            ) {
                                withAnimation {
                                    visualizationMode = .hidden
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            

                            Text("Background")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            MenuButton(
                                title: "Camera",
                                isSelected: backgroundMode == .camera
                            ) {
                                withAnimation {
                                    backgroundMode = .camera
                                }
                            }
                            
                            MenuButton(
                                title: "Black",
                                isSelected: backgroundMode == .black
                            ) {
                                withAnimation {
                                    backgroundMode = .black
                                }
                            }
                            MenuButton(
                                title: "White",
                                isSelected: backgroundMode == .white
                            ) {
                                withAnimation {
                                    backgroundMode = .white
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Button(action: {
                                showSettings = false
                                viewModel.currentTutorialStep = .drawSingle
                                viewModel.isTutorialTransitioning = false
                                withAnimation(.spring()) {
                                    viewModel.isTutorialActive = true
                                }
                            }) {
                                HStack {
                                    Text("View Tutorial")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: 220)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        .padding(.trailing, 50)
                        .padding(.top, 70)
                    }
                    
                    Spacer()
                }
                .transition(.scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.isDualHandMode = isDualMode
        }
    }
}

struct MenuButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.indigo)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
