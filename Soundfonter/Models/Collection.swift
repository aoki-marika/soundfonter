//
//  Collection.swift
//  Soundfonter
//
//  Created by marika on 2024-12-23.
//

import SwiftUI
import SwiftData

/// A named collection of instruments.
@Model
class Collection: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// The universally unique identifier for the favourites collection.
    static let favouritesId = UUID(uuidString: "12CD3324-0121-4842-AAE0-4591C388F36E")!
    
    @Attribute(.unique) var id: UUID
    
    /// The human-readable display name of this collection.
    var name: String
    
    /// The filesystem URL of this collection's directory, if any.
    private(set) var url: URL?
    
    /// All the instruments within this collection.
    var instruments: [Instrument]
    
    /// Whether or not this collection is the user favourites collection.
    var isFavourites: Bool {
        return id == Collection.favouritesId
    }
    
    // MARK: - Initializers
    
    init(_ name: String = "New Collection", instruments: [Instrument] = [], url: URL? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.instruments = instruments
        self.url = url
    }
    
    convenience init(_ name: String, instruments: [Instrument] = [], path: String) {
        self.init(name, instruments: instruments, url: URL(filePath: path))
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Collection, rhs: Collection) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
