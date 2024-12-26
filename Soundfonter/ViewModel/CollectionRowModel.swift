//
//  CollectionRowModel.swift
//  Soundfonter
//
//  Created by marika on 2024-12-25.
//

import SwiftUI

extension CollectionRow {
    
    @Observable
    class ViewModel {
        
        // MARK: - Properties
        
        /// The collection this row is displaying.
        var collection: Collection
        
        /// The closure to execute upon performing an action within the row.
        private let actionCallback: (Collection, Action) -> Void
        
        /// The system image icon for this view's collection.
        var icon: String {
            if collection.url != nil {
                return "waveform"
            }
            else {
                return collection.isFavourites ? "heart" : "folder"
            }
        }
        
        // MARK: - Initializers
        
        init(collection: Collection, actionCallback: @escaping (Collection, Action) -> Void) {
            self.collection = collection
            self.actionCallback = actionCallback
        }
        
        // MARK: - Methods
        
        /// Inform this model that the given action is being performed.
        /// - Parameter action: The action that is being performed.
        func perform(action: Action) {
            actionCallback(collection, action)
        }
    }
    
    // MARK: - Enumerations
    
    /// The different actions a row can perform.
    enum Action {
        /// Delete this collection from the library.
        case delete
        
        /// Reveal this collection in the Finder.
        case showInFinder
    }
}
