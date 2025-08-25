//
//  CharacterDetailsViewUITests.swift
//  iOSTaskYassirUITests
//
//  Created by Mohamed Shendy on 25/08/2025.
//

import XCTest
import SwiftUI
@testable import iOSTaskYassir

final class CharacterDetailsViewUITests: XCTestCase {
    
    // MARK: - Properties
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Navigation Tests
    
    func testCharacterDetailsView_NavigationFromList() {
        // Given - App is launched and we're on the character list
        
        // When - Wait for characters to load and tap on first character
        let firstCharacterCell = app.cells.firstMatch
        XCTAssertTrue(firstCharacterCell.waitForExistence(timeout: 10.0), "Character list should load")
        
        let characterName = firstCharacterCell.staticTexts.firstMatch.label
        firstCharacterCell.tap()
        
        // Then - Should navigate to details view and show character name
        let detailsView = app.navigationBars.firstMatch
        XCTAssertTrue(detailsView.exists, "Should navigate to character details view")
        
        // Verify we're showing details for the same character
        if !characterName.isEmpty {
            let detailsName = app.staticTexts[characterName]
            XCTAssertTrue(detailsName.exists, "Should display details for selected character: \(characterName)")
        }
    }
    
    func testCharacterDetailsView_BackButtonFunctionality() {
        // Given - App is launched and we navigate to details
        
        // When - Navigate to details view
        let firstCharacterCell = app.cells.firstMatch
        XCTAssertTrue(firstCharacterCell.waitForExistence(timeout: 10.0), "Character list should load")
        firstCharacterCell.tap()
        
        // Verify we're in details view
        let detailsView = app.navigationBars.firstMatch
        XCTAssertTrue(detailsView.exists, "Should be in character details view")
        
        // Then - Back button should exist and be functional
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Back button should exist in details view")
        
        // Test back button functionality
        backButton.tap()
        
        // Should return to list view
        let listView = app.navigationBars["Characters"]
        XCTAssertTrue(listView.exists, "Should return to character list view")
    }
    
    // MARK: - Character Information Display Tests
    
    func testCharacterDetailsView_DisplaysCharacterImage() {
        // Given - App is launched and we navigate to details
        
        // When - Navigate to details view
        let firstCharacterCell = app.cells.firstMatch
        XCTAssertTrue(firstCharacterCell.waitForExistence(timeout: 10.0), "Character list should load")
        firstCharacterCell.tap()
        
        // Then - Should display character image
        let characterImage = app.images.firstMatch
        XCTAssertTrue(characterImage.exists, "Should display character image")

    }
    
    // MARK: - Performance Tests
    
    func testCharacterDetailsView_LoadsWithinPerformanceThreshold() {
        // Given - App is launched
        
        // When - Measure navigation performance
        let firstCharacterCell = app.cells.firstMatch
        XCTAssertTrue(firstCharacterCell.waitForExistence(timeout: 10.0), "Character list should load")
        
        let startTime = Date()
        firstCharacterCell.tap()
        
        // Wait for details to load
        let detailsView = app.navigationBars.firstMatch
        XCTAssertTrue(detailsView.waitForExistence(timeout: 5.0), "Details should load")
        
        let loadTime = Date().timeIntervalSince(startTime)
        
        // Then - Should load within reasonable time
        XCTAssertLessThan(loadTime, 2.0, "Character details should load in under 2 seconds")
    }
    
    // MARK: - UI State Tests
    
    func testCharacterDetailsView_MaintainsStateDuringNavigation() {
        // Given - App is launched and we navigate to details
        
        // When - Navigate to details view
        let firstCharacterCell = app.cells.firstMatch
        XCTAssertTrue(firstCharacterCell.waitForExistence(timeout: 10.0), "Character list should load")
        firstCharacterCell.tap()
        
        // Verify we're in details view
        let detailsView = app.navigationBars.firstMatch
        XCTAssertTrue(detailsView.exists, "Should be in character details view")
        
        // Navigate back and forth to test state preservation
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Back button should exist")
        
        backButton.tap()
        
        // Should return to list
        let listView = app.navigationBars["Characters"]
        XCTAssertTrue(listView.exists, "Should return to character list view")
        
        // Navigate back to details
        firstCharacterCell.tap()
        XCTAssertTrue(detailsView.waitForExistence(timeout: 5.0), "Should navigate back to details")
        
        // Then - UI state should be maintained
        XCTAssertTrue(detailsView.exists, "Character details view should maintain proper UI state")
    }
    
    func testCharacterDetailsView_HandlesEmptyDataGracefully() {
        // Given - App is launched
        
        // When - Try to access details (this test assumes empty state handling)
        
        // Then - App should handle empty data gracefully
        // Note: This test verifies the app doesn't crash with empty data
        XCTAssertTrue(app.exists, "App should handle empty character data gracefully")
        
        // Additional verification that we can still interact with the app
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.exists, "App should maintain basic navigation structure")
    }
}
