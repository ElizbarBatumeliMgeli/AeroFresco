//
//  ColorPalettes.swift
//  hand_detection_test
//
//  Created by Elizbar Kheladze on 22/02/26.
//

import SwiftUI


struct ColorPalette: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
}


extension ColorPalette {
    static let palettes: [ColorPalette] = [
        ColorPalette(name: "Classic", colors: [.black, .red, .blue, .green, .yellow, .white]),
        ColorPalette(name: "Pastel Dream", colors: [
            Color(red: 1.0, green: 0.8, blue: 0.9),
            Color(red: 0.8, green: 0.9, blue: 1.0),
            Color(red: 1.0, green: 1.0, blue: 0.8),
            Color(red: 0.9, green: 0.8, blue: 1.0),
            Color(red: 0.8, green: 1.0, blue: 0.9),
            Color(red: 1.0, green: 0.9, blue: 0.8)
        ]),
        ColorPalette(name: "Ocean Waves", colors: [
            Color(red: 0.0, green: 0.2, blue: 0.4),
            Color(red: 0.0, green: 0.5, blue: 0.8),
            Color.cyan,
            Color(red: 0.4, green: 0.8, blue: 0.9),
            Color(red: 0.2, green: 0.6, blue: 0.7),
            Color.white
        ]),
        ColorPalette(name: "Sunset Vibes", colors: [
            Color(red: 0.5, green: 0.0, blue: 0.5),
            Color(red: 0.8, green: 0.2, blue: 0.4),
            Color(red: 1.0, green: 0.4, blue: 0.0),
            Color(red: 1.0, green: 0.6, blue: 0.2),
            Color(red: 1.0, green: 0.8, blue: 0.4),
            Color(red: 1.0, green: 0.9, blue: 0.7)
        ]),
        ColorPalette(name: "Forest Nature", colors: [
            Color(red: 0.2, green: 0.3, blue: 0.1),
            Color(red: 0.3, green: 0.5, blue: 0.2),
            Color(red: 0.5, green: 0.7, blue: 0.3),
            Color(red: 0.6, green: 0.4, blue: 0.2),
            Color(red: 0.8, green: 0.6, blue: 0.4),
            Color(red: 0.9, green: 0.9, blue: 0.8)
        ]),
        ColorPalette(name: "Monochrome", colors: [
            Color.black,
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.4, green: 0.4, blue: 0.4),
            Color(red: 0.6, green: 0.6, blue: 0.6),
            Color(red: 0.8, green: 0.8, blue: 0.8),
            Color.white
        ]),
        ColorPalette(name: "Neon Lights", colors: [
            Color(red: 1.0, green: 0.0, blue: 0.5),
            Color(red: 0.5, green: 0.0, blue: 1.0),
            Color(red: 0.0, green: 0.5, blue: 1.0),
            Color(red: 0.0, green: 1.0, blue: 0.5),
            Color(red: 1.0, green: 1.0, blue: 0.0),
            Color(red: 1.0, green: 0.3, blue: 0.0)
        ]),
        ColorPalette(name: "Autumn Leaves", colors: [
            Color(red: 0.6, green: 0.2, blue: 0.0),
            Color(red: 0.8, green: 0.3, blue: 0.0),
            Color(red: 1.0, green: 0.5, blue: 0.0),
            Color(red: 1.0, green: 0.7, blue: 0.2),
            Color(red: 0.7, green: 0.5, blue: 0.2),
            Color(red: 0.4, green: 0.2, blue: 0.1)
        ]),
        ColorPalette(name: "Cherry Blossom", colors: [
            Color(red: 1.0, green: 0.7, blue: 0.8),
            Color(red: 1.0, green: 0.5, blue: 0.7),
            Color(red: 0.9, green: 0.3, blue: 0.5),
            Color(red: 0.6, green: 0.2, blue: 0.3),
            Color(red: 0.4, green: 0.1, blue: 0.2),
            Color.white
        ]),
        ColorPalette(name: "Tropical Paradise", colors: [
            Color(red: 1.0, green: 0.3, blue: 0.5),
            Color(red: 1.0, green: 0.5, blue: 0.0),
            Color(red: 1.0, green: 0.9, blue: 0.0),
            Color(red: 0.0, green: 0.8, blue: 0.6),
            Color(red: 0.2, green: 0.6, blue: 0.9),
            Color(red: 0.1, green: 0.4, blue: 0.3)
        ]),
        ColorPalette(name: "Arctic Ice", colors: [
            Color(red: 0.9, green: 0.95, blue: 1.0),
            Color(red: 0.7, green: 0.85, blue: 0.95),
            Color(red: 0.5, green: 0.7, blue: 0.9),
            Color(red: 0.3, green: 0.5, blue: 0.7),
            Color(red: 0.2, green: 0.3, blue: 0.5),
            Color(red: 0.8, green: 0.9, blue: 0.95)
        ]),
        ColorPalette(name: "Desert Sand", colors: [
            Color(red: 0.95, green: 0.9, blue: 0.7),
            Color(red: 0.9, green: 0.7, blue: 0.5),
            Color(red: 0.8, green: 0.5, blue: 0.3),
            Color(red: 0.6, green: 0.4, blue: 0.2),
            Color(red: 0.9, green: 0.6, blue: 0.3),
            Color(red: 0.4, green: 0.3, blue: 0.2)
        ]),
        ColorPalette(name: "Candy Shop", colors: [
            Color(red: 1.0, green: 0.4, blue: 0.7),
            Color(red: 0.6, green: 0.4, blue: 1.0),
            Color(red: 0.4, green: 0.8, blue: 1.0),
            Color(red: 1.0, green: 0.8, blue: 0.0),
            Color(red: 1.0, green: 0.5, blue: 0.3),
            Color(red: 0.5, green: 1.0, blue: 0.5)
        ]),
        ColorPalette(name: "Royal Jewels", colors: [
            Color(red: 0.3, green: 0.0, blue: 0.5),
            Color(red: 0.0, green: 0.2, blue: 0.6),
            Color(red: 0.0, green: 0.5, blue: 0.3),
            Color(red: 0.7, green: 0.0, blue: 0.2),
            Color(red: 0.9, green: 0.7, blue: 0.0),
            Color(red: 0.6, green: 0.6, blue: 0.7)
        ]),
        ColorPalette(name: "Midnight Sky", colors: [
            Color(red: 0.05, green: 0.05, blue: 0.15),
            Color(red: 0.1, green: 0.1, blue: 0.3),
            Color(red: 0.2, green: 0.2, blue: 0.5),
            Color(red: 0.4, green: 0.3, blue: 0.6),
            Color(red: 0.9, green: 0.9, blue: 0.0),
            Color(red: 0.8, green: 0.8, blue: 0.9)
        ]),
        ColorPalette(name: "Garden Fresh", colors: [
            Color(red: 0.4, green: 0.8, blue: 0.4),
            Color(red: 0.6, green: 0.9, blue: 0.3),
            Color(red: 0.3, green: 0.6, blue: 0.3),
            Color(red: 0.9, green: 0.3, blue: 0.4),
            Color(red: 0.9, green: 0.6, blue: 0.9),
            Color(red: 1.0, green: 0.9, blue: 0.3)
        ]),
        ColorPalette(name: "Volcanic Fire", colors: [
            Color(red: 0.2, green: 0.0, blue: 0.0),
            Color(red: 0.5, green: 0.0, blue: 0.0),
            Color(red: 0.8, green: 0.1, blue: 0.0),
            Color(red: 1.0, green: 0.3, blue: 0.0),
            Color(red: 1.0, green: 0.6, blue: 0.0),
            Color(red: 1.0, green: 0.9, blue: 0.4)
        ]),
        ColorPalette(name: "Lavender Fields", colors: [
            Color(red: 0.9, green: 0.8, blue: 1.0),
            Color(red: 0.8, green: 0.6, blue: 0.9),
            Color(red: 0.6, green: 0.4, blue: 0.8),
            Color(red: 0.5, green: 0.3, blue: 0.7),
            Color(red: 0.4, green: 0.6, blue: 0.4),
            Color(red: 0.9, green: 0.9, blue: 0.95)
        ])
    ]
}
