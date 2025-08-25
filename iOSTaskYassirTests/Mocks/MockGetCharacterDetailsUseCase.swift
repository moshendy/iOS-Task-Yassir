//
//  MockGetCharacterDetailsUseCase.swift
//  YassirIOSTaskTests
//
//  Created by Mohamed Shendy on 24/08/2025.
//


import Foundation
import Combine
@testable import iOSTaskYassir

// MARK: - Mock Get Character Details Use Case
class MockGetCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol {
    
    // MARK: - Mock Properties
    var mockCharacter: Character?
    var shouldFail: Bool = false
    var mockError: AppError?
    var executeCallCount: Int = 0
    
    // MARK: - Mock Methods
    func execute(id: CharacterID) -> AnyPublisher<Character, AppError> {
        executeCallCount += 1
        
        if shouldFail {
            return Fail(error: mockError ?? .networkError("Mock use case failure"))
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
    
    // MARK: - Mock Setup Methods
    func setMockCharacter(_ character: Character) {
        mockCharacter = character
    }
    
    func setMockError(_ error: AppError) {
        mockError = error
        shouldFail = true
    }
    
    func reset() {
        mockCharacter = nil
        shouldFail = false
        mockError = nil
        executeCallCount = 0
    }
}
