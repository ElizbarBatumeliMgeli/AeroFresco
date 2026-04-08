//
//  GuideView.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 15/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    private let totalPages = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color.indigo, Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: geometry.size.width * 0.02) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: max(8, geometry.size.width * 0.025),
                                       height: max(8, geometry.size.width * 0.025))
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, geometry.size.height * 0.05)
                    .padding(.bottom, geometry.size.height * 0.02)
                    
                    TabView(selection: $currentPage) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            OnboardingPage(pageNumber: index + 1, size: geometry.size)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            if currentPage < totalPages - 1 {
                                currentPage += 1
                            } else {
                                dismiss()
                            }
                        }
                    }) {
                        Text(currentPage == totalPages - 1 ? "Get Started" : "Continue")
                            .font(.system(size: max(18, geometry.size.width * 0.04), weight: .bold, design: .rounded))
                            .foregroundColor(.indigo)
                            .frame(width: geometry.size.width * 0.6)
                            .padding(.vertical, max(16, geometry.size.height * 0.02))
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.bottom, geometry.size.height * 0.08)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let pageNumber: Int
    let size: CGSize
    
    var body: some View {
        VStack(spacing: size.height * 0.05) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: size.width * 0.5, height: size.width * 0.5)
                
                Image(systemName: pageIcon)
                    .font(.system(size: size.width * 0.2))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            }
            
            VStack(spacing: size.height * 0.02) {
                Text(pageTitle)
                    .font(.system(size: max(28, size.width * 0.08), weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(pageDescription)
                    .font(.system(size: max(18, size.width * 0.045), weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, size.width * 0.1)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var pageIcon: String {
        switch pageNumber {
        case 1: return "sparkles"
        case 2: return "sun.max.fill"
        case 3: return "hand.draw.fill"
        default: return "star.fill"
        }
    }
    
    private var pageTitle: String {
        switch pageNumber {
        case 1: return "AeroFresco"
        case 2: return "Perfect Lighting"
        case 3: return "Learn by Doing"
        default: return ""
        }
    }
    
    private var pageDescription: String {
        switch pageNumber {
        case 1:
            return "Welcome to the future of drawing. No screens to touch, just pure creativity in the air."
        case 2:
            return "Position yourself in a well-lit room. Good lighting ensures seamless and accurate hand tracking."
        case 3:
            return "Jump right in. A quick interactive tutorial will teach you the controls directly on the canvas."
        default:
            return ""
        }
    }
}
