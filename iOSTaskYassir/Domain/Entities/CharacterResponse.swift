//
//  CharacterResponse.swift
//  iOSTaskYassir
//
//  Created by Mohamed Shendy on 22/08/2025.
//

import Foundation


// MARK: - Domain Response Model
struct CharacterResponse: Equatable {
    let info: PaginationInfo
    let results: [Character]
    
    init(info: PaginationInfo, results: [Character]) {
        self.info = info
        self.results = results
    }
    
    var hasMorePages: Bool {
        info.next != nil
    }
    
    var currentPage: Int {
        info.currentPage
    }
    
    var totalPages: Int {
        info.pages
    }
    
    var totalCharacters: Int {
        info.count
    }
}

// MARK: - Pagination Info
struct PaginationInfo: Equatable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
    
    init(count: Int, pages: Int, next: String?, prev: String?) {
        self.count = count
        self.pages = pages
        self.next = next
        self.prev = prev
    }
    
    var currentPage: Int {
        if let prev = prev, let pageNumber = extractPageNumber(from: prev) {
            return pageNumber + 1
        }
        return 1
    }
    
    private func extractPageNumber(from url: String) -> Int? {
        guard let url = URL(string: url),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let pageParam = components.queryItems?.first(where: { $0.name == "page" }),
              let pageValue = pageParam.value else {
            return nil
        }
        return Int(pageValue)
    }
}
