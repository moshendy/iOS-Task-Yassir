//
//  iOSTaskYassirApp.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 23/08/2025.
//

import SwiftUI

@main
struct iOSTaskYassirApp: App {
    
    init() {
        // Configure dependency injection container
        ServiceConfiguration.configureServices()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
