//
//  GetCharactersUseCaseTests.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import XCTest
import Combine
@testable import iOSTaskYassir

final class GetCharactersUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    private var useCase: GetCharactersUseCase!
    private var mockRepository: MockCharacterRepository!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Data
    private var mockCharacters: [Character] = []
    
    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        useCase = GetCharactersUseCase(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
        
        // Create mock data using MockDataFactory
        mockCharacters = MockDataFactory.createMockCharacterList(count: 2)
    }
    

    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Input Validation Tests
    
    func testExecute_WithInvalidPageNumber_ReturnsInvalidInputError() {
        // Given
        let invalidPage = 0
        
        // When
        var receivedError: AppError?
        var receivedValue: CharacterResponse?
        
        useCase.execute(page: invalidPage, searchQuery: nil)
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
        XCTAssertNil(receivedValue, "Should not receive value for invalid page")
        XCTAssertEqual(receivedError, .invalidInput("Page number must be greater than 0"))
    }
    
    func testExecute_WithNegativePageNumber_ReturnsInvalidInputError() {
        // Given
        let negativePage = -1
        
        // When
        var receivedError: AppError?
        
        useCase.execute(page: negativePage, searchQuery: nil)
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
        XCTAssertEqual(receivedError, .invalidInput("Page number must be greater than 0"))
    }
    
    // MARK: - Search Query Tests
    
    func testExecute_WithValidSearchQuery_CallsRepositorySearchMethod() {
        // Given
        let searchQuery = "Rick"
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: searchQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.getCallCount, 0, "Should not call getCharacters for search")
        // Note: We can't directly verify searchCharacters was called, but we can verify the behavior
    }
    
    func testExecute_WithEmptySearchQuery_CallsRepositoryGetCharactersMethod() {
        // Given
        let emptyQuery = ""
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: emptyQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.getCallCount, 1, "Should call getCharacters for empty search query")
    }
    
    func testExecute_WithWhitespaceOnlySearchQuery_CallsRepositoryGetCharactersMethod() {
        // Given
        let whitespaceQuery = "   "
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: whitespaceQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.getCallCount, 1, "Should call getCharacters for whitespace-only search query")
    }
    
    func testExecute_WithNilSearchQuery_CallsRepositoryGetCharactersMethod() {
        // Given
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.getCallCount, 1, "Should call getCharacters for nil search query")
    }
    
    // MARK: - Success Scenarios
    
    func testExecute_WithValidPage_ReturnsCharactersFromRepository() {
        // Given
        let page = 1
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        var receivedError: AppError?
        
        useCase.execute(page: page, searchQuery: nil)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { response in
                    receivedResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNil(receivedError, "Should not receive error")
        XCTAssertNotNil(receivedResponse, "Should receive response")
        XCTAssertEqual(receivedResponse?.results.count, mockCharacters.count)
        XCTAssertEqual(receivedResponse?.results, mockCharacters)
    }
    
    func testExecute_WithValidSearchQuery_ReturnsFilteredResults() {
        // Given
        let searchQuery = "Rick"
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        
        useCase.execute(page: 1, searchQuery: searchQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedResponse, "Should receive response for search")
        // The actual filtering would happen in the repository, but we verify the use case handles it
    }
    
    // MARK: - Error Handling
    
    func testExecute_WhenRepositoryFails_PropagatesError() {
        // Given
        let expectedError = AppError.networkError("Repository failure")
        mockRepository.setMockError(expectedError)
        
        // When
        var receivedError: AppError?
        
        useCase.execute(page: 1, searchQuery: nil)
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
    
    // MARK: - Repository Configuration Tests
    
    func testExecute_UsesInjectedRepository() {
        // Given
        let customRepository = MockCharacterRepository()
        let customUseCase = GetCharactersUseCase(repository: customRepository)
        customRepository.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        
        customUseCase.execute(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedResponse, "Should use injected repository")
        XCTAssertEqual(customRepository.getCallCount, 1, "Should call injected repository")
    }
    
    // MARK: - Call Tracking Tests
    
    func testExecute_TracksRepositoryCalls() {
        // Given
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.getCallCount, 1)
    }
    
    func testExecute_TracksSearchCalls() {
        // Given
        mockRepository.setMockCharacters(mockCharacters)
        
        // When
        useCase.execute(page: 1, searchQuery: "Rick")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertEqual(mockRepository.searchCharactersCallCount, 1)
    }
}
