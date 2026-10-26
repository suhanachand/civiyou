//
//  CiviComponents.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//


import SwiftUI

struct CiviCard<Content: View>: View {
    var color: Color = CiviYouTheme.white
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(color)
            )
            .shadow(
                color: CiviYouTheme.charcoal.opacity(0.06),
                radius: 12,
                y: 5
            )
    }
}

struct CiviSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(CiviYouTheme.heading(23))
                .foregroundStyle(CiviYouTheme.charcoal)

            if let subtitle {
                Text(subtitle)
                    .font(CiviYouTheme.body(13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CiviPill: View {
    let title: String
    var color: Color = CiviYouTheme.yellow

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(CiviYouTheme.charcoal)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(color.opacity(0.75), in: Capsule())
    }
}

struct CiviPrimaryButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: symbol)
            }
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(.white)
            .padding(17)
            .background(
                CiviYouTheme.charcoal,
                in: RoundedRectangle(cornerRadius: 17)
            )
        }
        .buttonStyle(.plain)
    }
}

struct BookmarkButton: View {
    let isSaved: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(CiviYouTheme.charcoal)
                .frame(width: 43, height: 43)
                .background(
                    .white.opacity(0.8),
                    in: Circle()
                )
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isSaved ? "Remove bookmark" : "Save bookmark"
        )
    }
}
