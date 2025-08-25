//
//  GetCharacterDetailsUseCase.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 22/08/2025.
//

import Foundation
import Combine

// MARK: - Get Character Details Use Case Protocol
protocol GetCharacterDetailsUseCaseProtocol {
    func execute(id: CharacterID) -> AnyPublisher<Character, AppError>
}

// MARK: - Get Character Details Use Case Implementation
class GetCharacterDetailsUseCase: GetCharacterDetailsUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol
    
    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: CharacterID) -> AnyPublisher<Character, AppError> {
        // Validate input parameters
        guard id.value > 0 else {
            return Fail(error: AppError.invalidInput("Character ID must be greater than 0"))
                .eraseToAnyPublisher()
        }
        
        return repository.getCharacterDetails(id: id)
    }
}

// MARK: - Get Character Details Use Case Factory
class GetCharacterDetailsUseCaseFactory {
    static func create() -> GetCharacterDetailsUseCase {
        let repository = CharacterRepositoryFactory.create()
        return GetCharacterDetailsUseCase(repository: repository)
    }
}
