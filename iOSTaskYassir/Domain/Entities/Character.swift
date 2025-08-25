//
//  Character.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 22/08/2025.
//

import Foundation

// MARK: - Core Domain Entity
struct Character: Identifiable, Equatable {
    let id: CharacterID
    let name: CharacterName
    let status: CharacterStatus
    let species: CharacterSpecies
    let type: CharacterType
    let gender: CharacterGender
    let origin: CharacterLocation
    let location: CharacterLocation
    let image: CharacterImage
    let episodes: [EpisodeID]
    let url: CharacterURL
    let created: CharacterCreatedDate
    
    init(
        id: CharacterID,
        name: CharacterName,
        status: CharacterStatus,
        species: CharacterSpecies,
        type: CharacterType,
        gender: CharacterGender,
        origin: CharacterLocation,
        location: CharacterLocation,
        image: CharacterImage,
        episodes: [EpisodeID],
        url: CharacterURL,
        created: CharacterCreatedDate
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.origin = origin
        self.location = location
        self.image = image
        self.episodes = episodes
        self.url = url
        self.created = created
    }
}

// MARK: - Value Objects
struct CharacterID: Equatable, Hashable {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

struct CharacterName: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
    
    var isValid: Bool {
        value.count >= 2
    }
}

struct CharacterStatus: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isAlive: Bool {
        value.lowercased() == "alive"
    }
    
    var isDead: Bool {
        value.lowercased() == "dead"
    }
    
    var isUnknown: Bool {
        value.lowercased() == "unknown"
    }
}

struct CharacterSpecies: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
}

struct CharacterType: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
    
    var displayValue: String {
        value.isEmpty ? "Unknown" : value
    }
}

struct CharacterGender: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
}

struct CharacterLocation: Equatable {
    let name: String
    let url: String
    
    init(name: String, url: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        name.isEmpty
    }
}

struct CharacterImage: Equatable {
    let url: String
    
    init(_ url: String) {
        self.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValid: Bool {
        !url.isEmpty && URL(string: url) != nil
    }
}

struct EpisodeID: Equatable, Hashable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
}

struct CharacterURL: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        value.isEmpty
    }
}

struct CharacterCreatedDate: Equatable {
    let value: Date
    
    init(_ value: Date) {
        self.value = value
    }
    
    init(from string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.value = formatter.date(from: string) ?? Date()
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: value, relativeTo: Date())
    }
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: value)
    }
}
