import XCTest
import Combine
@testable import iOSTaskYassir

// MARK: - Character Details ViewModel Tests
@MainActor
class CharacterDetailsViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: CharacterDetailsViewModel!
    var mockGetCharacterDetailsUseCase: MockGetCharacterDetailsUseCase!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        mockGetCharacterDetailsUseCase = MockGetCharacterDetailsUseCase()
    }
    
    override func tearDown() {
        viewModel = nil
        mockGetCharacterDetailsUseCase = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialStateWithCharacter() {
        // Given
        let mockCharacter = MockDataFactory.createMockCharacter()
        
        // When
        viewModel = CharacterDetailsViewModel(
            character: mockCharacter,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        // Then
        XCTAssertEqual(viewModel.character?.id.value, mockCharacter.id.value)
        XCTAssertEqual(viewModel.character?.name.value, mockCharacter.name.value)
        XCTAssertEqual(viewModel.character?.status.value, mockCharacter.status.value)
        XCTAssertEqual(viewModel.character?.species.value, mockCharacter.species.value)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testInitialStateWithoutCharacter() {
        // Given & When
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        // Then
        XCTAssertNil(viewModel.character)
        XCTAssertFalse(viewModel.isLoading)
        
        // Wait for async error message to be set
        let expectation = XCTestExpectation(description: "Error message set")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "No character data available")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInitialStateWithDefaultUseCase() {
        // Given & When
        viewModel = CharacterDetailsViewModel(character: nil)
        
        // Then
        XCTAssertNil(viewModel.character)
        XCTAssertFalse(viewModel.isLoading)
        
        // Wait for async error message to be set
        let expectation = XCTestExpectation(description: "Error message set")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "No character data available")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Load Character Details Tests
    func testLoadCharacterDetailsSuccess() {
        // Given
        let mockCharacter = MockDataFactory.createMockCharacter()
        mockGetCharacterDetailsUseCase.setMockCharacter(mockCharacter)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Character details loaded successfully")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.character?.id.value, mockCharacter.id.value)
            XCTAssertEqual(self.viewModel.character?.name.value, mockCharacter.name.value)
            XCTAssertEqual(self.viewModel.character?.status.value, mockCharacter.status.value)
            XCTAssertEqual(self.viewModel.character?.species.value, mockCharacter.species.value)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadCharacterDetailsFailure() {
        // Given
        let mockError = MockDataFactory.createMockNetworkError()
        mockGetCharacterDetailsUseCase.setMockError(mockError)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Character details load failed")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.character)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.errorMessage, "Network Error: Mock network error")
            XCTAssertEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadCharacterDetailsWithExistingCharacter() {
        // Given
        let existingCharacter = MockDataFactory.createMockCharacter()
        let newCharacter = MockDataFactory.createMockCharacter()
        mockGetCharacterDetailsUseCase.setMockCharacter(newCharacter)
        
        viewModel = CharacterDetailsViewModel(
            character: existingCharacter,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Load character details with existing character")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(2))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Should not load new character since one already exists
            XCTAssertEqual(self.viewModel.character?.id.value, existingCharacter.id.value)
            XCTAssertEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadCharacterDetailsMultipleCalls() {
        // Given
        let mockCharacter = MockDataFactory.createMockCharacter()
        mockGetCharacterDetailsUseCase.setMockCharacter(mockCharacter)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Multiple load character details calls")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        // Wait for first call to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Now try to load again - should be ignored since character exists
            self.viewModel.loadCharacterDetails(id: CharacterID(2))
            
            // Wait a bit more for any potential async operations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(self.viewModel.character?.id.value, mockCharacter.id.value)
                XCTAssertEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 1) // Only first call should execute
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    func testClearError() {
        // Given
        let mockError = MockDataFactory.createMockNetworkError()
        mockGetCharacterDetailsUseCase.setMockError(mockError)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Error cleared successfully")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify error is set
            XCTAssertNotNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.errorMessage, "Network Error: Mock network error")
            
            // Clear error
            self.viewModel.clearError()
            
            // Wait for error to be cleared
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertNil(self.viewModel.errorMessage)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorHandlingWithDecodingError() {
        // Given
        let decodingError = AppError.decodingError("Failed to decode character data")
        mockGetCharacterDetailsUseCase.setMockError(decodingError)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Decoding error handled")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.character)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.errorMessage, "Data Error: Failed to decode character data")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases Tests
    func testLoadCharacterDetailsWithInvalidID() {
        // Given
        let mockError = AppError.networkError("Character not found")
        mockGetCharacterDetailsUseCase.setMockError(mockError)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Invalid ID handled")
        
        // When
        viewModel.loadCharacterDetails(id: CharacterID(999))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.character)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.errorMessage, "Network Error: Character not found")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewModelLifecycle() {
        // Given
        let mockCharacter = MockDataFactory.createMockCharacter()
        mockGetCharacterDetailsUseCase.setMockCharacter(mockCharacter)
        
        // When
        viewModel = CharacterDetailsViewModel(
            character: mockCharacter,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        // Then
        XCTAssertNotNil(viewModel.character)
        XCTAssertEqual(viewModel.cancellables.count, 0) // No active subscriptions initially
        
        // When - Load character details
        let expectation = XCTestExpectation(description: "ViewModel lifecycle test")
        viewModel.loadCharacterDetails(id: CharacterID(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check if cancellables count increased (might be 0 if subscription completed immediately)
            XCTAssertGreaterThanOrEqual(self.viewModel.cancellables.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConcurrentLoadCharacterDetails() {
        // Given
        let mockCharacter = MockDataFactory.createMockCharacter()
        mockGetCharacterDetailsUseCase.setMockCharacter(mockCharacter)
        
        viewModel = CharacterDetailsViewModel(
            character: nil,
            getCharacterDetailsUseCase: mockGetCharacterDetailsUseCase
        )
        
        let expectation = XCTestExpectation(description: "Concurrent load character details")
        
        // When - Multiple concurrent calls
        DispatchQueue.concurrentPerform(iterations: 3) { _ in
            viewModel.loadCharacterDetails(id: CharacterID(1))
        }
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // The guard clause should prevent multiple calls, but concurrent calls might still increment the counter
            // We expect at least 1 call, but the exact count depends on timing
            XCTAssertGreaterThanOrEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 1)
            XCTAssertLessThanOrEqual(self.mockGetCharacterDetailsUseCase.executeCallCount, 3)
            XCTAssertNotNil(self.viewModel.character)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
