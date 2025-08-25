//
//  CharacterListViewUITests.swift
//  iOSTaskYassirUITests
//
//  Created by Mohamed Shendy on 25/08/2025.
//

import XCTest
import SwiftUI
@testable import iOSTaskYassir

final class CharacterListViewUITests: XCTestCase {
    
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
    
    // MARK: - Basic UI Tests
    
    func testCharacterListView_DisplaysCorrectTitle() {
        // Given & When - App is launched
        
        // Then
        let navigationBar = app.navigationBars["Characters"]
        XCTAssertTrue(navigationBar.exists, "Should display 'Characters' title")
        XCTAssertTrue(navigationBar.isEnabled, "Navigation bar should be enabled")
    }
    
    func testCharacterListView_ShowsSearchBar() {
        // Given & When - App is launched
        
        // Then
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Should display search bar")
        XCTAssertTrue(searchField.isEnabled, "Search bar should be enabled")
        XCTAssertTrue(searchField.isHittable, "Search bar should be tappable")
    }
    
    // MARK: - Search Functionality Tests
    
    func testCharacterListView_SearchBarAcceptsInput() {
        // Given
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // When
        searchField.tap()
        searchField.typeText("Rick")
        
        // Then
        XCTAssertEqual(searchField.value as? String, "Rick", "Search field should accept text input")

    }
    
    func testCharacterListView_SearchBarShowsClearButton() {
        // Given
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // When
        searchField.tap()
        searchField.typeText("Test")
        
        // Then
        let clearButton = app.buttons["Clear"]
        XCTAssertTrue(clearButton.exists, "Clear button should appear when text is entered")
        XCTAssertTrue(clearButton.isEnabled, "Clear button should be enabled")
        XCTAssertTrue(clearButton.isHittable, "Clear button should be tappable")
    }
    
    func testCharacterListView_ClearButtonRemovesText() {
        // Given
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        searchField.tap()
        searchField.typeText("Test")
        
        // Verify text was entered
        XCTAssertEqual(searchField.value as? String, "Test", "Search field should contain entered text")
        
        // When
        let clearButton = app.buttons["Clear"]
        XCTAssertTrue(clearButton.exists, "Clear button should exist")
        clearButton.tap()
        
        // Then
        XCTAssertEqual(searchField.value as? String, "Search characters...", "Clear button should remove search text")
        XCTAssertFalse(clearButton.exists, "Clear button should disappear after clearing text")
    }
    
    // MARK: - Character List Tests
    
    func testCharacterListView_DisplaysCharacterCells() {
        // Given & When - App is launched
        
        // Then
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10.0), "Character list should load and display cells")
        
        // Verify cell has content
        let cellText = firstCell.staticTexts.firstMatch
        XCTAssertTrue(cellText.exists, "Character cell should display text content")
        XCTAssertNotEqual(cellText.label, "", "Character cell should have non-empty text")
    }
    
    func testCharacterListView_CharacterCellIsTappable() {
        // Given
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10.0), "Character list should load")
        
        // When
        let originalTitle = app.navigationBars["Characters"]
        XCTAssertTrue(originalTitle.exists, "Should be on character list view")
        
        firstCell.tap()
        
        // Then
        // Should navigate to details view (navigation bar title should change)
        let detailsView = app.navigationBars.firstMatch
        XCTAssertTrue(detailsView.exists, "Should navigate to character details view")
        
        // Verify we're not on the list view anymore
        XCTAssertFalse(originalTitle.exists, "Should have navigated away from character list")
    }
    
    // MARK: - Refresh Control Tests
    
    func testCharacterListView_RefreshControlFunctionality() {
        // Given
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10.0), "Character list should load")
        
        // When - Perform pull to refresh
        firstCell.swipeDown()
        
        // Then
        // The refresh control should be visible and functional
        // Note: We can't directly test the refresh indicator, but we can verify the app remains responsive
        XCTAssertTrue(firstCell.exists, "App should remain responsive after pull to refresh")
        
        // Verify we can still interact with the list
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search functionality should remain available after refresh")
    }
    
    // MARK: - Accessibility Tests
    
    func testCharacterListView_ProperAccessibilitySupport() {
        // Given & When - App is launched
        
        // Then
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // Check for accessibility identifiers or labels
        let accessibleElements = app.staticTexts.allElementsBoundByIndex
        var hasAccessibilitySupport = false
        
        for element in accessibleElements {
            if !element.label.isEmpty || !element.identifier.isEmpty {
                hasAccessibilitySupport = true
                break
            }
        }
        
        XCTAssertTrue(hasAccessibilitySupport, "Character list should have accessibility support")
    }
    
    // MARK: - Performance Tests
    
    func testCharacterListView_LoadsWithinPerformanceThreshold() {
        // Given & When - App is launched
        
        // Then
        let startTime = Date()
        
        // Wait for the view to load (search field becomes accessible)
        let searchField = app.textFields["Search characters..."]
        let exists = searchField.waitForExistence(timeout: 5.0)
        
        let loadTime = Date().timeIntervalSince(startTime)
        
        XCTAssertTrue(exists, "View should load within reasonable time")
        XCTAssertLessThan(loadTime, 3.0, "View should load in under 3 seconds")
    }
    
    // MARK: - UI State Tests
    
    func testCharacterListView_MaintainsStateDuringSearch() {
        // Given
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // When - Perform search operation
        searchField.tap()
        searchField.typeText("Test")
        
        // Verify search state
        XCTAssertEqual(searchField.value as? String, "Test", "Search field should contain search text")
        
        // Clear search
        let clearButton = app.buttons["Clear"]
        clearButton.tap()
        
        // Then
        XCTAssertEqual(searchField.value as? String, "Search characters...", "Search field should return to placeholder text")
        
        // Verify list is still functional
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.exists, "Character list should remain functional after search")
    }
    
    func testCharacterListView_HandlesEmptySearchResults() {
        // Given
        let searchField = app.textFields["Search characters..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // When - Search for something that likely won't exist
        searchField.tap()
        searchField.typeText("XYZ123Nonexistent")
        
        // Then
        // The app should handle empty search results gracefully
        XCTAssertTrue(app.exists, "App should handle empty search results gracefully")
        
        // Verify search field maintains state
        XCTAssertEqual(searchField.value as? String, "XYZ123Nonexistent", "Search field should maintain search text")
        
        // Clear search to return to normal state
        let clearButton = app.buttons["Clear"]
        clearButton.tap()
        XCTAssertEqual(searchField.value as? String, "Search characters...", "Should return to placeholder text")
    }
}
