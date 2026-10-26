//
//  CiviYouTheme.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import SwiftUI

enum CiviYouTheme {
    static let cream = Color(hex: 0xFFF9EB)
    static let pink = Color(hex: 0xF58BCC)
    static let yellow = Color(hex: 0xFFD633)
    static let blue = Color(hex: 0x79C7E8)
    static let mint = Color(hex: 0x39C9A3)
    static let peach = Color(hex: 0xFF987C)
    static let charcoal = Color(hex: 0x25221F)
    static let white = Color.white

    static func heading(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
