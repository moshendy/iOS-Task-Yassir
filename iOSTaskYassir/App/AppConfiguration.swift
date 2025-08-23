//
//  ContentView.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 22/08/2025.
//

import Foundation

struct AppConfiguration {
    static let appName = "Rick & Morty Characters"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // API Configuration
    struct API {
        static let baseURL = "https://rickandmortyapi.com/api"
        static let timeout: TimeInterval = 30
        static let charactersPerPage = 20
    }
    
    // Cache Configuration
    struct Cache {
        static let expirationTime: TimeInterval = 3600 // 1 hour
        static let maxCacheSize = 100 // Maximum number of characters to cache
    }
    
    // UI Configuration
    struct UI {
        static let searchDebounceTime: TimeInterval = 0.5
        static let imageCornerRadius: CGFloat = 8
        static let listRowSpacing: CGFloat = 8
    }
}
