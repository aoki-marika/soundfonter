//
//  LibraryCommands.swift
//  Soundfonter
//
//  Created by marika on 2024-12-25.
//

import SwiftUI

/// Commands for managing a `LibraryView`.
struct LibraryCommands: Commands {
    
    // MARK: - Properties

    /// The library that these commands are managing.
    let library: Library
    
    @FocusedValue(\.selectedCollection) var selectedCollection
    @FocusedValue(\.selectedInstrument) var selectedInstrument
    @FocusedValue(\.collectionViewModel) var collectionViewModel
    @FocusedValue(\.libraryViewModel) var libraryViewModel
    @FocusedValue(\.isSearching) var isSearching
    
    // MARK: - Commands
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Collection") {
                let collection = Collection()
                library.userCollections.append(collection)
                selectedCollection?.wrappedValue = collection
            }
            .keyboardShortcut("n", modifiers: [.control, .command])
            
            Button("Open Library") {
                libraryViewModel?.importStatus = .importing
            }
            .keyboardShortcut("o")
        }
        
        CommandGroup(before: CommandGroupPlacement.textEditing) {
            Button("Find...") {
                isSearching?.wrappedValue = true
            }
            .keyboardShortcut("f")
        }
        
        CommandMenu("Instrument") {
            collectionViewModel?.buildFavouriteMenu(for: selectedInstrument?.wrappedValue, in: library, shortcuts: true)
            collectionViewModel?.buildUserCollectionMenu(for: selectedInstrument?.wrappedValue, in: library, shortcuts: true)
        }
    }
}
