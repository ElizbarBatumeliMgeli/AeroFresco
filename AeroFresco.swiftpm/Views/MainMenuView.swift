//
//  MainMenuView.swift
//  AirCanvas
//
//  Created by Elizbar Kheladze on 09/02/26.
//

import SwiftUI

enum MenuState {
    case main
    case modeSelection
}

enum CanvasRoute: Hashable {
    case singleHand
    case dualHand
}

struct MainMenuView: View {
    @State private var navigationPath = NavigationPath()
    @State private var menuState: MenuState = .main
    @State private var showOnboarding = false
    @AppStorage("hasSeenOnboardingFlow") private var hasSeenOnboardingFlow = false
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [Color.indigo, Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 400)
                    .offset(x: -300, y: -200)
                
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 300)
                    .offset(x: 300, y: 200)
                
                VStack(spacing: 40) {
                    headerSection
                    Spacer()
                    menuContent
                    Spacer()
                    backButton
                }
            }
            .navigationDestination(for: CanvasRoute.self) { route in
                switch route {
                case .singleHand:
                    ContentView(path: $navigationPath, isDualMode: false)
                case .dualHand:
                    ContentView(path: $navigationPath, isDualMode: true)
                }
            }
            .onAppear {
                menuState = .main
                
                if !hasSeenOnboardingFlow {
                    showOnboarding = true
                    hasSeenOnboardingFlow = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
        }
        .accentColor(.white)
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("AeroFresco")
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
            
            Text(menuState == .modeSelection ? "Choose Your Mode" : "Touchless Creativity")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .tracking(2)
                .contentTransition(.numericText())
                .animation(.default, value: menuState)
        }
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var menuContent: some View {
        ZStack {
            if menuState == .main {
                VStack(spacing: 30) {
                    MenuPill(title: "START", icon: "play.fill", color: .green) {
                        haptic.impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            menuState = .modeSelection
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            } else if menuState == .modeSelection {
                VStack(spacing: 30) {
                    MenuPill(title: "Single Hand", icon: "hand.raised.fill", color: .orange) {
                        haptic.impactOccurred()
                        navigationPath.append(CanvasRoute.singleHand)
                    }
                    
                    MenuPill(title: "Dual Hand", icon: "hands.clap.fill", color: .purple) {
                        haptic.impactOccurred()
                        navigationPath.append(CanvasRoute.dualHand)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
    
    @ViewBuilder
    private var backButton: some View {
        if menuState != .main {
            Button(action: {
                haptic.impactOccurred(intensity: 0.6)
                withAnimation(.spring()) {
                    menuState = .main
                }
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 40)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            Color.clear
                .frame(height: 50)
                .padding(.bottom, 40)
        }
    }
}
