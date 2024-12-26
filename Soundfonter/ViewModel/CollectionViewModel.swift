//
//  CollectionViewModel.swift
//  Soundfonter
//
//  Created by marika on 2024-12-25.
//

import SwiftUI

extension CollectionView {

    @Observable
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        
        /// The collection this view is displaying.
        let collection: Collection

        /// The currently selected instrument within the view.
        let selectedInstrument: Binding<Instrument?>
        
        /// The unique identifier of the currently selected instrument within the view.
        private(set) var selectedInstrumentId: Binding<Instrument.ID?>
        
        /// The closure to execute upon performing an action within the view.
        private let actionCallback: (Instrument, Action) -> Void
        
        // MARK: - Initializers
        
        init(collection: Collection, selectedInstrument: Binding<Instrument?>, actionCallback: @escaping (Instrument, Action) -> Void) {
            self.collection = collection
            self.selectedInstrument = selectedInstrument
            self.actionCallback = actionCallback

            // table doesnt support object selection :real:
            self.selectedInstrumentId = .constant(nil)
            self.selectedInstrumentId = Binding<Instrument.ID?>(get: {
                return self.selectedInstrument.wrappedValue?.id
            }, set: { newValue, _ in
                self.selectedInstrument.wrappedValue = collection.instruments.first(where: { $0.id == newValue })
            })
        }
        
        // MARK: - Methods
        
        /// Get the instruments within the view's collection filtered by the given search query.
        /// - Parameter filter: The search query to filter by.
        /// - Returns: The filtered results.
        func getFilteredInstruments(with filter: String) -> [Instrument] {
            return collection.instruments.filter {
                var matchesFilter = true

                let cleanFilter = filter.trimmingCharacters(in: .whitespaces).lowercased()
                if !cleanFilter.isEmpty {
                    matchesFilter =
                        $0.name.lowercased().contains(cleanFilter)
                        || String($0.number).contains(cleanFilter)
                        || String($0.bank).contains(cleanFilter)
                }
                
                return matchesFilter
            }
        }
        
        /// Build a menu for managing the favourite state of the given instrument.
        /// - Parameter instrument: The instrument to create the menu for. If `nil` the menu will not perform actions.
        /// - Parameter library: The library to manage the favourite state within.
        /// - Parameter shortcut: Whether or not to include keyboard shortcuts.
        /// - Returns: The menu.
        func buildFavouriteMenu(for instrument: Instrument?, in library: Library, shortcuts: Bool = false) -> some View {
            let isFavourited = isFavourite(instrument: instrument, in: library)
            
            return Button(isFavourited ? "Remove Favourite" : "Favourite", systemImage: isFavourited ? "heart.fill" : "heart") {
                guard let instrument else {
                    return
                }

                if isFavourited {
                    self.perform(action: .removeFrom(collection: library.favourites), instrument: instrument)
                }
                else {
                    self.perform(action: .addTo(collection: library.favourites), instrument: instrument)
                }
            }
            .if(shortcuts) {
                $0.keyboardShortcut("1")
            }
            .disabled(instrument == nil)
        }
        
        /// Build a menu for managing the user collections that the given instrument belongs to,
        /// - Parameter instrument: The instrument to create the menu for. If `nil` the menu will not perform actions.
        /// - Parameter library: The library to manage the collections within.
        /// - Parameter shortcut: Whether or not to include keyboard shortcuts.
        /// - Returns: The menu.
        func buildUserCollectionMenu(for instrument: Instrument?, in library: Library, shortcuts: Bool = false) -> some View {
            Menu("Add to Collection", systemImage: "folder") {
                Button("New Collection") {
                    guard let instrument else {
                        return
                    }

                    self.perform(action: .addToNewCollection, instrument: instrument)
                }
                .if(shortcuts) {
                    $0.keyboardShortcut("n", modifiers: [.shift, .command])
                }
                
                if !library.userCollections.isEmpty {
                    Divider()
                    
                    ForEach(library.userCollections) { collection in
                        Toggle("\(collection.name)", isOn: Binding<Bool>(get: {
                            guard let instrument else {
                                return false
                            }
                            
                            return collection.instruments.contains(instrument)
                        }, set: {
                            guard let instrument else {
                                return
                            }
                            
                            if $0 {
                                self.perform(action: .addTo(collection: collection), instrument: instrument)
                            }
                            else {
                                self.perform(action: .removeFrom(collection: collection), instrument: instrument)
                            }
                        }))
                    }
                }
            }
            .disabled(instrument == nil)
        }
        
        /// Inform this model that the given action is being performed.
        /// /// - Parameter action: The action that is being performed.
        /// - Parameter instrument: The instrument that the action is being performed on.
        func perform(action: Action, instrument: Instrument) {
            actionCallback(instrument, action)
        }
        
        /// Get the favourite state of the given instrument.
        /// - Parameter instrument: The instrument to get the favourite state of.
        /// - Parameter library: The library to check the favourite state within.
        /// - Returns: Whether or not the given instrument is favourited.
        private func isFavourite(instrument: Instrument?, in library: Library) -> Bool {
            guard let instrument else {
                return false
            }
            
            return library.favourites.instruments.contains(instrument)
        }
    }
    
    // MARK: - Enumerations
    
    /// The different actions a view can perform.
    enum Action {
        /// Add this instrument to the given collection.
        case addTo(collection: Collection)
        
        /// Create a new collection and add this instrument to it.
        case addToNewCollection
        
        /// Remove this instrument to the given collection.
        case removeFrom(collection: Collection)
        
        /// Reveal this instrument in the Finder.
        case showInFinder
    }
}

// MARK: - Extensions

extension FocusedValues {
    struct FocusedIsSearchingKey: FocusedValueKey {
        typealias Value = Binding<Bool>
    }
    
    struct FocusedCollectionViewModelKey: FocusedValueKey {
        typealias Value = CollectionView.ViewModel
    }
    
    var isSearching: Binding<Bool>? {
        get { self[FocusedIsSearchingKey.self] }
        set { self[FocusedIsSearchingKey.self] = newValue }
    }
    
    var collectionViewModel: CollectionView.ViewModel? {
        get { self[FocusedCollectionViewModelKey.self] }
        set { self[FocusedCollectionViewModelKey.self] = newValue }
    }
}
