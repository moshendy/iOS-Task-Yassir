//
//  CharacterRepositoryTests.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 25/08/2025.
//

import XCTest
import Combine
@testable import iOSTaskYassir

final class CharacterRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    private var repository: CharacterRepository!
    private var mockAPIService: MockCharacterAPIService!
    private var mockRealmManager: MockRealmManager!
    private var mockNetworkManager: MockNetworkManager!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Data
    private var mockCharacters: [Character]!
    private var mockCharacterResponse: CharacterResponse!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockAPIService = MockCharacterAPIService()
        mockRealmManager = MockRealmManager()
        mockNetworkManager = MockNetworkManager()
        cancellables = Set<AnyCancellable>()
        
        // Create test data
        mockCharacters = MockDataFactory.createMockCharacterList(count: 5)
        mockCharacterResponse = MockDataFactory.createMockCharacterResponse(
            characters: mockCharacters,
            page: 1,
            totalPages: 2
        )
        
        repository = CharacterRepository(
            apiService: mockAPIService,
            realmManager: mockRealmManager,
            networkManager: mockNetworkManager,
            configuration: .default
        )
    }
    
    override func tearDown() {
        repository = nil
        mockAPIService = nil
        mockRealmManager = nil
        mockNetworkManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Get Characters Tests
    
    func testGetCharacters_WithValidPage_ReturnsCharactersFromAPI() {
        // Given
        let mockDTO = createMockCharacterResponseDTO(from: mockCharacterResponse)
        mockAPIService.setMockResponse(mockDTO)
        
        // When
        var receivedResponse: CharacterResponse?
        var receivedError: AppError?
        
        repository.getCharacters(page: 1, searchQuery: nil)
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
        XCTAssertEqual(receivedResponse?.info.count, mockCharacters.count)
        XCTAssertEqual(receivedResponse?.info.pages, 2)
    }
    
    func testGetCharacters_WhenAPIFails_ReturnsCachedDataIfOfflineModeEnabled() {
        // Given
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        mockRealmManager.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        var receivedError: AppError?
        
        repository.getCharacters(page: 1, searchQuery: nil)
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
        XCTAssertNil(receivedError, "Should not receive error when offline mode enabled")
        XCTAssertNotNil(receivedResponse, "Should receive cached response")
        XCTAssertEqual(receivedResponse?.results.count, mockCharacters.count)
    }
    
    func testGetCharacters_WhenAPIFailsAndOfflineModeDisabled_ReturnsError() {
        // Given
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        
        let offlineDisabledConfig = RepositoryConfiguration(
            charactersPerPage: 20,
            maxCacheAge: 300,
            enableOfflineMode: false
        )
        
        repository = CharacterRepository(
            apiService: mockAPIService,
            realmManager: mockRealmManager,
            networkManager: mockNetworkManager,
            configuration: offlineDisabledConfig
        )
        
        // When
        var receivedError: AppError?
        
        repository.getCharacters(page: 1, searchQuery: nil)
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
        XCTAssertNotNil(receivedError, "Should receive error when offline mode disabled")
        XCTAssertEqual(receivedError?.localizedDescription, "Network Error: API failure")
    }
    
    func testGetCharacters_SavesSuccessfulResponseToCache() {
        // Given
        let mockDTO = createMockCharacterResponseDTO(from: mockCharacterResponse)
        mockAPIService.setMockResponse(mockDTO)
        
        // When
        repository.getCharacters(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        // Then
        // The repository should call saveCharactersToCache internally
        // We can verify this by checking if the mock was called
        XCTAssertTrue(mockRealmManager.saveCharactersCalled, "Should save characters to cache")
    }
    
    // MARK: - Get Character Details Tests
    
    func testGetCharacterDetails_WithValidID_ReturnsCharacterFromAPI() {
        // Given
        let mockCharacter = mockCharacters[0]
        let mockCharacterDTO = createMockCharacterDTO(from: mockCharacter)
        mockAPIService.setMockCharacter(mockCharacterDTO)
        
        // When
        var receivedCharacter: Character?
        var receivedError: AppError?
        
        repository.getCharacterDetails(id: CharacterID(1))
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
        XCTAssertEqual(receivedCharacter?.id.value, 1)
        XCTAssertEqual(receivedCharacter?.name.value, mockCharacter.name.value)
    }
    
    func testGetCharacterDetails_WhenAPIFails_ReturnsError() {
        // Given
        let mockError = AppError.networkError("Character not found")
        mockAPIService.setMockError(mockError)
        
        // When
        var receivedError: AppError?
        
        repository.getCharacterDetails(id: CharacterID(999))
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
        XCTAssertNotNil(receivedError, "Should receive error")
        XCTAssertEqual(receivedError?.localizedDescription, "Network Error: Character not found")
    }
    
    // MARK: - Search Characters Tests
    
    func testSearchCharacters_WithValidQuery_ReturnsFilteredResults() {
        // Given
        let searchQuery = "Character" // This will match all mock characters since they're named "Character 1", "Character 2", etc.
        let mockDTO = createMockCharacterResponseDTO(from: mockCharacterResponse)
        mockAPIService.setMockResponse(mockDTO)
        
        // When
        var receivedResponse: CharacterResponse?
        var receivedError: AppError?
        
        repository.searchCharacters(query: searchQuery)
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
        XCTAssertNotNil(receivedResponse, "Should receive search response")
        XCTAssertEqual(receivedResponse?.results.count, mockCharacters.count)
        
        // Test case-insensitive search as well
        let uppercaseQuery = "CHARACTER"
        var uppercaseResponse: CharacterResponse?
        
        repository.searchCharacters(query: uppercaseQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    uppercaseResponse = response
                }
            )
            .store(in: &cancellables)
        
        XCTAssertNotNil(uppercaseResponse, "Should receive case-insensitive search response")
        XCTAssertEqual(uppercaseResponse?.results.count, mockCharacters.count, "Case-insensitive search should return same results")
    }
    
    func testSearchCharacters_WhenAPIFails_ReturnsCachedSearchResults() {
        // Given
        let searchQuery = "Character" // This will match all mock characters since they're named "Character 1", "Character 2", etc.
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        mockRealmManager.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        var receivedError: AppError?
        
        repository.searchCharacters(query: searchQuery)
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
        XCTAssertNil(receivedError, "Should not receive error when offline mode enabled")
        XCTAssertNotNil(receivedResponse, "Should receive cached search results")
        XCTAssertEqual(receivedResponse?.results.count, mockCharacters.count, "Should return all 5 characters that match 'Character'")
    }
    
    // MARK: - Caching Tests
    
    func testGetCharacters_WithPagination_ReturnsCorrectPageFromCache() {
        // Given
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        mockRealmManager.setMockCharacters(mockCharacters)
        
        // When - Request page 1 (should return all 5 characters)
        var receivedResponsePage1: CharacterResponse?
        repository.getCharacters(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponsePage1 = response
                }
            )
            .store(in: &cancellables)
        
        // When - Request page 2 (should return empty since we only have 5 characters and page size is 20)
        var receivedResponsePage2: CharacterResponse?
        repository.getCharacters(page: 2, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponsePage2 = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        // Page 1 should have all 5 characters
        XCTAssertNotNil(receivedResponsePage1, "Should receive page 1 response from cache")
        XCTAssertEqual(receivedResponsePage1?.results.count, 5, "Page 1 should have all 5 characters")
        XCTAssertEqual(receivedResponsePage1?.info.count, 5, "Total count should be 5 characters")
        XCTAssertEqual(receivedResponsePage1?.info.pages, 1, "Should have only 1 page with 5 characters")
        
        // Page 2 should be empty since we only have 5 characters and page size is 20
        XCTAssertNotNil(receivedResponsePage2, "Should receive page 2 response from cache")
        XCTAssertEqual(receivedResponsePage2?.results.count, 0, "Page 2 should be empty when requesting beyond available cached data")
        XCTAssertEqual(receivedResponsePage2?.info.count, 5, "Total count should be 5 characters")
        XCTAssertEqual(receivedResponsePage2?.info.pages, 1, "Should have only 1 page with 5 characters")
    }
    

    
    func testSearchCharacters_WithNoMatchingQuery_ReturnsEmptyResults() {
        // Given
        let searchQuery = "Zombie" // This won't match any mock characters
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        mockRealmManager.setMockCharacters(mockCharacters)
        
        // When
        var receivedResponse: CharacterResponse?
        
        repository.searchCharacters(query: searchQuery)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponse = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedResponse, "Should receive empty search results")
        XCTAssertEqual(receivedResponse?.results.count, 0, "Should return 0 characters for non-matching query")
        XCTAssertEqual(receivedResponse?.info.count, 0, "Total count should be 0 for no matches")
    }
    

    
    func testGetCharacters_WithRealPagination_ReturnsCorrectPagesFromCache() {
        // Given
        let mockError = AppError.networkError("API failure")
        mockAPIService.setMockError(mockError)
        
        // Create 25 characters to test real pagination (page size is 20)
        let manyCharacters = MockDataFactory.createMockCharacterList(count: 25)
        mockRealmManager.setMockCharacters(manyCharacters)
        
        // When - Request page 1 (should return first 20 characters)
        var receivedResponsePage1: CharacterResponse?
        repository.getCharacters(page: 1, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponsePage1 = response
                }
            )
            .store(in: &cancellables)
        
        // When - Request page 2 (should return remaining 5 characters)
        var receivedResponsePage2: CharacterResponse?
        repository.getCharacters(page: 2, searchQuery: nil)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    receivedResponsePage2 = response
                }
            )
            .store(in: &cancellables)
        
        // Then
        // Page 1 should have 20 characters
        XCTAssertNotNil(receivedResponsePage1, "Should receive page 1 response from cache")
        XCTAssertEqual(receivedResponsePage1?.results.count, 20, "Page 1 should have 20 characters")
        XCTAssertEqual(receivedResponsePage1?.info.count, 25, "Total count should be 25 characters")
        XCTAssertEqual(receivedResponsePage1?.info.pages, 2, "Should have 2 pages")
        XCTAssertNotNil(receivedResponsePage1?.info.next, "Page 1 should have next page")
        XCTAssertNil(receivedResponsePage1?.info.prev, "Page 1 should not have previous page")
        
        // Page 2 should have 5 characters
        XCTAssertNotNil(receivedResponsePage2, "Should receive page 2 response from cache")
        XCTAssertEqual(receivedResponsePage2?.results.count, 5, "Page 2 should have 5 characters")
        XCTAssertEqual(receivedResponsePage2?.info.count, 25, "Total count should be 25 characters")
        XCTAssertEqual(receivedResponsePage2?.info.pages, 2, "Should have 2 pages")
        XCTAssertNil(receivedResponsePage2?.info.next, "Page 2 should not have next page")
        XCTAssertNotNil(receivedResponsePage2?.info.prev, "Page 2 should have previous page")
    }
            
    // MARK: - Helper Methods
    
    private func createMockCharacterDTO(from character: Character) -> CharacterDTO {
        return CharacterDTO(
            id: character.id.value,
            name: character.name.value,
            status: character.status.value,
            species: character.species.value,
            type: character.type.value,
            gender: character.gender.value,
            origin: LocationDTO(name: character.origin.name, url: character.origin.url),
            location: LocationDTO(name: character.location.name, url: character.location.url),
            image: character.image.url,
            episode: character.episodes.map { $0.value },
            url: character.url.value,
            created: "2023-01-01T00:00:00.000Z"
        )
    }
    
    private func createMockCharacterResponseDTO(from response: CharacterResponse) -> CharacterResponseDTO {
        let infoDTO = InfoDTO(
            count: response.info.count,
            pages: response.info.pages,
            next: response.info.next,
            prev: response.info.prev
        )
        
        let characterDTOs = response.results.map { createMockCharacterDTO(from: $0) }
        
        return CharacterResponseDTO(
            info: infoDTO,
            results: characterDTOs
        )
    }
}
