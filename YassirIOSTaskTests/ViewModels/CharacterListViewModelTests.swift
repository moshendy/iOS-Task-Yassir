//
//  CharacterListViewModelTests.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import XCTest
import Combine
@testable import iOSTaskYassir

// MARK: - Character List ViewModel Tests
class CharacterListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: CharacterListViewModel!
    var mockGetCharactersUseCase: MockGetCharactersUseCase!
    var mockNetworkManager: MockNetworkManager!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        mockGetCharactersUseCase = MockGetCharactersUseCase()
        mockNetworkManager = MockNetworkManager()
        
        viewModel = CharacterListViewModel(
            getCharactersUseCase: mockGetCharactersUseCase,
            networkManager: mockNetworkManager,
            configuration: .default
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockGetCharactersUseCase = nil
        mockNetworkManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(viewModel.characters.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isOffline)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasMorePages)
    }
    
    // MARK: - Load Characters Tests
    func testLoadCharactersSuccess() {
        // Given
        let mockCharacters = MockDataFactory.createMockCharacterList(count: 3)
        let mockResponse = MockDataFactory.createMockCharacterResponse(characters: mockCharacters)
        mockGetCharactersUseCase.setMockCharacters(mockCharacters)
        
        let expectation = XCTestExpectation(description: "Characters loaded successfully")
        
        // When
        viewModel.loadCharacters()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.characters.count, 3)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.viewModel.hasMorePages)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadCharactersFailure() {
        // Given
        let mockError = MockDataFactory.createMockNetworkError()
        mockGetCharactersUseCase.setMockError(mockError)
        
        let expectation = XCTestExpectation(description: "Characters load failed")
        
        // When
        viewModel.loadCharacters()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.characters.count, 0)
            XCTAssertFalse(self.viewModel.isLoading)
            // The ViewModel shows a specific message for network errors
            XCTAssertNotNil(self.viewModel.errorMessage)
            // Check for the exact message the ViewModel shows
            XCTAssertEqual(self.viewModel.errorMessage, "No internet connection. Showing cached data if available.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Search Tests
    func testSearchCharactersSuccess() {
        // Given
        let mockCharacters = MockDataFactory.createMockCharacterList(count: 2)
        mockGetCharactersUseCase.setMockCharacters(mockCharacters)
        
        let expectation = XCTestExpectation(description: "Search completed successfully")
        
        // When
        viewModel.searchText = "Rick"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Wait for debounce
            XCTAssertTrue(self.viewModel.isSearching)
            XCTAssertEqual(self.viewModel.characters.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCharactersEmptyQuery() {
        // Given
        let mockCharacters = MockDataFactory.createMockCharacterList(count: 5)
        
        // Create a fresh mock and ViewModel for this test to avoid initialization issues
        let testMock = MockGetCharactersUseCase()
        testMock.setMockCharacters(mockCharacters)
        
        let testViewModel = CharacterListViewModel(
            getCharactersUseCase: testMock,
            networkManager: mockNetworkManager,
            configuration: .default
        )
        
        let expectation = XCTestExpectation(description: "Empty search loads all characters")
        
        // When
        // First set some search text to trigger search mode
        testViewModel.searchText = "test"
        
        // Wait for the search to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Then clear it to trigger empty search
            testViewModel.searchText = ""
            
            // Wait for the debounced search text change to complete (0.5 seconds debounce)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                XCTAssertFalse(testViewModel.isSearching)
                // The empty search should trigger loadCharacters() which loads 5 characters
                XCTAssertEqual(testViewModel.characters.count, 5)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Pagination Tests
    func testLoadMoreCharacters() {
        // Given
        let initialCharacters = MockDataFactory.createMockCharacterList(count: 3)
        let moreCharacters = MockDataFactory.createMockCharacterList(count: 2)
        
        // Set up mock to return different characters for different calls
        mockGetCharactersUseCase.setMockCharacters(initialCharacters)
        
        let expectation = XCTestExpectation(description: "More characters loaded")
        
        // When
        viewModel.loadCharacters()
        
        // Change mock to return more characters for the second call
        mockGetCharactersUseCase.setMockCharacters(moreCharacters)
        viewModel.loadMoreCharacters()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.characters.count, 5)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHasMorePages() {
        // Given
        let mockCharacters = MockDataFactory.createMockCharacterList(count: 5)
        mockGetCharactersUseCase.setMockCharacters(mockCharacters)
        
        let expectation = XCTestExpectation(description: "Has more pages check completed")
        
        // When
        viewModel.loadCharacters()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.hasMorePages)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Network Status Tests
    func testNetworkStatusConnected() {
        // Given
        mockNetworkManager.setConnected(true)
        
        // When
        viewModel.refresh()
        
        // Then
        XCTAssertFalse(viewModel.isOffline)
    }
    
    func testNetworkStatusDisconnected() {
        // Given
        mockNetworkManager.setConnected(false)
        
        // When
        viewModel.refresh()
        
        // Then
        XCTAssertTrue(viewModel.isOffline)
    }
    
    // MARK: - Error Handling Tests
    func testClearError() {
        // Given
        let mockError = MockDataFactory.createMockNetworkError()
        mockGetCharactersUseCase.setMockError(mockError)
        
        // When
        viewModel.loadCharacters()
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testRefresh() {
        // Given
        let mockCharacters = MockDataFactory.createMockCharacterList(count: 4)
        mockGetCharactersUseCase.setMockCharacters(mockCharacters)
        
        let expectation = XCTestExpectation(description: "Refresh completed")
        
        // When
        viewModel.refresh()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.characters.count, 4)
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
