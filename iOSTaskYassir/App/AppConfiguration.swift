//
//  AppConfiguration.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 22/08/2025.
//

import Foundation

struct AppConfiguration {
    // API Configuration
    struct API {
        static let baseURL = "https://rickandmortyapi.com/api"
    }
    
    // Cache Configuration
    struct Cache {
        static let expirationTime: TimeInterval = AppConstants.Cache.defaultExpirationTime
    }
}
