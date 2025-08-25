//
//  MockCharacterAPIService.swift
//  iOSTaskYassirTests
//
//  Created by Mohamed Shendy on 25/08/2025.
//

import Foundation
import Combine
@testable import iOSTaskYassir

// MARK: - Mock Character API Service
class MockCharacterAPIService: CharacterAPIServiceProtocol {
    private var mockResponse: CharacterResponseDTO?
    private var mockCharacter: CharacterDTO?
    private var mockError: AppError?
    
    func setMockResponse(_ response: CharacterResponseDTO) {
        mockResponse = response
    }
    
    func setMockCharacter(_ character: CharacterDTO) {
        mockCharacter = character
    }
    
    func setMockError(_ error: AppError) {
        mockError = error
    }
    
    func getCharacters(page: Int, searchQuery: String?) -> AnyPublisher<CharacterResponseDTO, AppError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockResponse {
            return Just(response).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
        
        return Fail(error: .networkError("No mock response configured")).eraseToAnyPublisher()
    }
    
    func getCharacterDetails(id: Int) -> AnyPublisher<CharacterDTO, AppError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let character = mockCharacter {
            return Just(character).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
        
        return Fail(error: .networkError("No mock character configured")).eraseToAnyPublisher()
    }
}
