//
//  Library.swift
//  Soundfonter
//
//  Created by marika on 2024-12-24.
//

import SwiftUI
import SwiftData

/// A library of soundfonts and user collections.
@Model
class Library: ObservableObject, Equatable {
    
    // MARK: - Properties
    
    /// The security-scoped bookmark to this library's directory, if any.
    private var bookmarkData: Data?
    
    /// All the soundfonts within this library.
    @Transient var soundfonts = [Collection]()
    
    /// The favourite instruments within this library.
    var favourites = Collection("Favourites", id: Collection.favouritesId)
    
    /// All the user-created collections within this library.
    var userCollections = [Collection]()
    
    /// The filesystem URL of this library's directory, if any.
    var url: URL? {
        get {
            guard let bookmarkData else {
                return nil
            }

            var isStale = false
            guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], bookmarkDataIsStale: &isStale), !isStale else {
                return nil
            }
            
            return url
        }
        set {
            guard let url = newValue, url.startAccessingSecurityScopedResource() else {
                bookmarkData = nil
                return
            }
            
            bookmarkData = try? url.bookmarkData(options: [.withSecurityScope])
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    // MARK: - Initializers
    
    init() {
        self.soundfonts = []
        self.userCollections = []
    }
    
    convenience init(soundfonts: [Collection], favourites: Collection, userCollections: [Collection]) {
        self.init()
        self.soundfonts = soundfonts
        self.favourites = favourites
        self.userCollections = userCollections
    }
    
    // MARK: - Methods
    
    /// Attempt to access this library's files within the given action.
    /// - Parameter action: The closure to execute to read or write files.
    func accessFiles(action: (URL) throws -> Void) throws {
        guard let url, url.startAccessingSecurityScopedResource() else {
            throw LibraryError.noAccess
        }
        
        try action(url)
        url.stopAccessingSecurityScopedResource()
    }
    
    /// Load the soundfonts within this library's directory, removing all existing soundfonts.
    func loadSoundfonts() throws {
        try accessFiles { url in
            // directory format is as follows:
            // /ARIAConverted/sf2/[soundfont name]_sf2/[bank ###]/[[number ###]_instrument].sfz
            // enumerate all files and categorize by soundfont directory
            
            let sf2Url = url.appendingPathComponent("ARIAConverted/sf2", conformingTo: .folder)
            guard FileManager.default.fileExists(atPath: sf2Url.path()) else {
                throw LibraryError.invalidFiles
            }
            
            let enumerator = FileManager.default.enumerator(atPath: sf2Url.path())
            guard let paths = enumerator?.allObjects as? [String] else {
                throw LibraryError.invalidFiles
            }
            
            soundfonts = []
            for directory in paths.filter({ $0.hasSuffix("_sf2") && !$0.contains("/") }) {
                let name = directory.replacingOccurrences(of: "_sf2", with: "").split(separator: "_").joined(separator: " ")
                let instrumentPaths = paths.filter({ $0.hasPrefix("\(directory)/") && $0.hasSuffix(".sfz") })
                let instruments = instrumentPaths.map { Instrument(url: sf2Url.appendingPathComponent($0)) }.sorted {
                    // sort by bank then number to match sforzando
                    if $0.bank == $1.bank {
                        $0.number < $1.number
                    }
                    else {
                        $0.bank < $1.bank
                    }
                }
                
                self.soundfonts.append(Collection(name, instruments: instruments, url: sf2Url.appendingPathComponent(directory)))
            }
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Library, rhs: Library) -> Bool {
        return lhs.soundfonts == rhs.soundfonts
            && lhs.favourites == rhs.favourites
            && lhs.userCollections == rhs.userCollections
    }
    
    // MARK: - Enumerations
    
    /// The different errors that can occur within a library.
    enum LibraryError: Error {
        /// The application does not have access to the given library files.
        case noAccess
        
        /// The library files are in an invalid or unknown format.
        case invalidFiles
    }
}
