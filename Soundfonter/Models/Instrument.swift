//
//  Instrument.swift
//  Soundfonter
//
//  Created by marika on 2024-12-23.
//

import SwiftUI
import SwiftData

/// An instrument that can be played.
@Model
class Instrument: Identifiable, Equatable, Hashable, Transferable {
    
    // MARK: - Properties
    
    /// The filesystem URL of the file for this instrument.
    @Attribute(.unique) private(set) var url: URL

    /// The number of this instrument within its bank.
    var number: Int {
        let filename = url.lastPathComponent
        let number = filename.split(separator: "_").first ?? "-1"
        return Int(number) ?? -1
    }
    
    /// The human-readable display name of this instrument.
    var name: String {
        let filename = url.deletingPathExtension().lastPathComponent
        let name = filename.split(separator: "_").dropFirst().joined(separator: " ")
        return name
    }

    /// The number of the bank containing this instrument.
    var bank: Int {
        let parentFilename = url.deletingLastPathComponent().lastPathComponent
        return Int(parentFilename) ?? -1
    }
    
    var id: String {
        return url.absoluteString
    }
    
    // MARK: - Initializers
    
    init(url: URL) {
        self.url = url
    }
    
    convenience init(path: String) {
        self.init(url: URL(filePath: path))
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Instrument, rhs: Instrument) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Transferable
    
    static var transferRepresentation: some TransferRepresentation {
        return DataRepresentation(contentType: .fileURL) { instrument in
            instrument.url.dataRepresentation
        } importing: { data in
            Instrument(url: URL(dataRepresentation: data, relativeTo: nil) ?? URL(filePath: ""))
        }
    }
}
