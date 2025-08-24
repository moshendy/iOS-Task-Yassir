//
//  MockCharacterRepository.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import Foundation
import Combine
@testable import iOSTaskYassir

// MARK: - Mock Character Repository
class MockCharacterRepository: CharacterRepositoryProtocol {
    
    // MARK: - Mock Properties
    var mockCharacters: [Character] = []
    var mockCharacter: Character?
    var shouldFail: Bool = false
    var mockError: AppError?
    var getCallCount: Int = 0
    
    // MARK: - Mock Methods
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError> {
        getCallCount += 1
        
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock repository failure"))
                .eraseToAnyPublisher()
        }
        
        let response = CharacterResponse(
            info: PaginationInfo(
                count: mockCharacters.count,
                pages: 2, // Simulate multiple pages
                next: "https://api.example.com/characters?page=2", // Simulate next page
                prev: nil
            ),
            results: mockCharacters
        )
        
        return Just(response)
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetails(id: CharacterID) -> AnyPublisher<Character, AppError> {
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock repository failure"))
                .eraseToAnyPublisher()
        }
        
        if let character = mockCharacter {
            return Just(character)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: .networkError("Character not found"))
            .eraseToAnyPublisher()
    }
    
    func searchCharacters(query: String) -> AnyPublisher<CharacterResponse, AppError> {
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock repository failure"))
                .eraseToAnyPublisher()
        }
        
        let response = CharacterResponse(
            info: PaginationInfo(
                count: mockCharacters.count,
                pages: 2, // Simulate multiple pages
                next: "https://api.example.com/characters?page=2", // Simulate next page
                prev: nil
            ),
            results: mockCharacters
        )
        
        return Just(response)
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Setup Methods
    func setMockCharacters(_ characters: [Character]) {
        mockCharacters = characters
    }
    
    func setMockCharacter(_ character: Character) {
        mockCharacter = character
    }
    
    func setMockError(_ error: AppError) {
        mockError = error
        shouldFail = true
    }
    
    func reset() {
        mockCharacters = []
        mockCharacter = nil
        shouldFail = false
        mockError = nil
        getCallCount = 0
    }
}
