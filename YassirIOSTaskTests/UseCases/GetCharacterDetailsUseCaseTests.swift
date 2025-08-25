//
//  GetCharacterDetailsUseCaseTests.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import XCTest
import Combine
@testable import iOSTaskYassir

final class GetCharacterDetailsUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    private var useCase: GetCharacterDetailsUseCase!
    private var mockRepository: MockCharacterRepository!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Data
    private let mockCharacter = Character(
        id: CharacterID(1),
        name: CharacterName("Rick Sanchez"),
        status: CharacterStatus("Alive"),
        species: CharacterSpecies("Human"),
        type: CharacterType(""),
        gender: CharacterGender("Male"),
        origin: CharacterLocation(name: "Earth", url: "https://example.com/earth"),
        location: CharacterLocation(name: "Earth", url: "https://example.com/earth"),
        image: CharacterImage("https://example.com/rick.jpg"),
        episodes: [EpisodeID("https://example.com/episode/1")],
        url: CharacterURL("https://example.com/character/1"),
        created: CharacterCreatedDate(from: "2023-01-01T00:00:00.000Z")
    )
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        useCase = GetCharacterDetailsUseCase(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Input Validation Tests
    
    func testExecute_WithInvalidCharacterID_ReturnsInvalidInputError() {
        // Given
        let invalidID = CharacterID(0)
        
        // When
        var receivedError: AppError?
        var receivedValue: Character?
        
        useCase.execute(id: invalidID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { value in
                    receivedValue = value
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNil(receivedValue, "Should not receive value for invalid ID")
        XCTAssertEqual(receivedError, .invalidInput("Character ID must be greater than 0"))
    }
    
    func testExecute_WithNegativeCharacterID_ReturnsInvalidInputError() {
        // Given
        let negativeID = CharacterID(-1)
        
        // When
        var receivedError: AppError?
        
        useCase.execute(id: negativeID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(receivedError, .invalidInput("Character ID must be greater than 0"))
    }
    
    // MARK: - Success Scenarios
    
    func testExecute_WithValidCharacterID_ReturnsCharacterFromRepository() {
        // Given
        let validID = CharacterID(1)
        mockRepository.setMockCharacter(mockCharacter)
        
        // When
        var receivedCharacter: Character?
        var receivedError: AppError?
        
        useCase.execute(id: validID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { character in
                    receivedCharacter = character
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNil(receivedError, "Should not receive error")
        XCTAssertNotNil(receivedCharacter, "Should receive character")
        XCTAssertEqual(receivedCharacter?.id, validID)
        XCTAssertEqual(receivedCharacter?.name.value, mockCharacter.name.value)
        XCTAssertEqual(receivedCharacter?.status.value, mockCharacter.status.value)
    }
    

    
    // MARK: - Error Handling
    
    func testExecute_WhenRepositoryFails_PropagatesError() {
        // Given
        let validID = CharacterID(1)
        let expectedError = AppError.networkError("Repository failure")
        mockRepository.setMockError(expectedError)
        
        // When
        var receivedError: AppError?
        
        useCase.execute(id: validID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(receivedError, expectedError)
    }
    
    func testExecute_WhenCharacterNotFound_PropagatesRepositoryError() {
        // Given
        let validID = CharacterID(999)
        // Don't set mock character, so repository will return "Character not found" error
        
        // When
        var receivedError: AppError?
        
        useCase.execute(id: validID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedError, "Should receive error when character not found")
        XCTAssertEqual(receivedError?.localizedDescription, "Network Error: Character not found")
    }
    
    // MARK: - Edge Cases
    
    func testExecute_WithMinimumValidCharacterID_WorksCorrectly() {
        // Given
        let minimumID = CharacterID(1)
        mockRepository.setMockCharacter(mockCharacter)
        
        // When
        var receivedCharacter: Character?
        
        useCase.execute(id: minimumID)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { character in
                    receivedCharacter = character
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedCharacter, "Should handle minimum valid ID correctly")
        XCTAssertEqual(receivedCharacter?.id.value, 1)
    }
    
    // MARK: - Repository Configuration Tests
    
    func testExecute_UsesInjectedRepository() {
        // Given
        let customRepository = MockCharacterRepository()
        let customUseCase = GetCharacterDetailsUseCase(repository: customRepository)
        customRepository.setMockCharacter(mockCharacter)
        
        // When
        var receivedCharacter: Character?
        
        customUseCase.execute(id: CharacterID(1))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { character in
                    receivedCharacter = character
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedCharacter, "Should use injected repository")
        XCTAssertEqual(receivedCharacter?.id.value, 1)
    }
    
}
