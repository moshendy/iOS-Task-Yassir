//
//  CharacterStatusUtils.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 24/08/2025.
//
import SwiftUI

// MARK: - Character Status Utilities
struct CharacterStatusUtils {
    
    static func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return AppColors.statusAlive
        case "dead":
            return AppColors.statusDead
        default:
            return AppColors.statusUnknown
        }
    }
    
    static func statusIcon(for status: String) -> String {
        switch status.lowercased() {
        case "alive":
            return "heart.fill"
        case "dead":
            return "skull"
        default:
            return "questionmark.circle"
        }
    }
    
    static func statusBackgroundColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return AppColors.statusAlive.opacity(0.1)
        case "dead":
            return AppColors.statusDead.opacity(0.1)
        default:
            return AppColors.statusUnknown.opacity(0.1)
        }
    }
}

// MARK: - Character Extensions
extension Character {
    var statusColor: Color {
        CharacterStatusUtils.statusColor(for: status.value)
    }
    
    var statusIcon: String {
        CharacterStatusUtils.statusIcon(for: status.value)
    }
    
    var statusBackgroundColor: Color {
        CharacterStatusUtils.statusBackgroundColor(for: status.value)
    }
}
