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
    var getCharacterDetailsCallCount: Int = 0
    var searchCharactersCallCount: Int = 0
    
    // MARK: - Mock Methods
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError> {
        getCallCount += 1
        
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock repository failure"))
                .eraseToAnyPublisher()
        }
        
        // Use MockDataFactory for consistency
        let response = MockDataFactory.createMockCharacterResponse(
            characters: mockCharacters,
            page: page,
            totalPages: 2
        )
        
        return Just(response)
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetails(id: CharacterID) -> AnyPublisher<Character, AppError> {
        getCharacterDetailsCallCount += 1
        
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
        searchCharactersCallCount += 1
        
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock repository failure"))
                .eraseToAnyPublisher()
        }
        
        // Use MockDataFactory for consistency
        let response = MockDataFactory.createMockCharacterResponse(
            characters: mockCharacters,
            page: 1,
            totalPages: 2
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
        getCharacterDetailsCallCount = 0
        searchCharactersCallCount = 0
    }
}
