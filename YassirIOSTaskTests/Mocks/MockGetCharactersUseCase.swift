//
//  MockGetCharactersUseCase.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//

import Foundation
import Combine
@testable import iOSTaskYassir

// MARK: - Mock Get Characters Use Case
class MockGetCharactersUseCase: GetCharactersUseCaseProtocol {
    
    // MARK: - Mock Properties
    var mockCharacters: [Character] = []
    var shouldFail: Bool = false
    var mockError: AppError?
    var executeCallCount: Int = 0
    
    // MARK: - Mock Methods
    func execute(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponse, AppError> {
        executeCallCount += 1
        
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock use case failure"))
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
    
    func setMockError(_ error: AppError) {
        mockError = error
        shouldFail = true
    }
    
    func reset() {
        mockCharacters = []
        shouldFail = false
        mockError = nil
        executeCallCount = 0
    }
}
