//
//  SidebarView.swift
//  Soundfonter
//
//  Created by marika on 2024-12-24.
//

import SwiftUI

struct SidebarView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var library: Library
    @State private var model: ViewModel
    
    // MARK: - View
    
    var body: some View {
        List(selection: model.selectedCollection) {
            Section("Soundfonts") {
                ForEach(library.soundfonts) { soundfont in
                    CollectionRow(soundfont, action: perform)
                }
            }
 
            Section("Collections") {
                CollectionRow(library.favourites, action: perform)
                
                ForEach(library.userCollections) { collection in
                    CollectionRow(collection, action: perform)
                }
            }
        }
        .contextMenu {
            Button("New Collection") {
                let collection = Collection()
                library.userCollections.append(collection)
                model.selectedCollection.wrappedValue = collection
            }
        }
        .onAppear {
            resetSelection()
        }
        .onChange(of: library.soundfonts) { _, _ in
            resetSelection()
        }
    }
    
    // MARK: - Initializers
    
    init(selectedCollection: Binding<Collection?>) {
        self.model = ViewModel(selectedCollection: selectedCollection)
    }
    
    // MARK: - Methods
    
    /// Perform the given collection action within this view.
    /// - Parameter collection: The collection performing this action.
    /// - Parameter action: The action to perform.
    func perform(collection: Collection, action: CollectionRow.Action) {
        switch action {
        case .delete:
            guard let index = library.userCollections.firstIndex(of: collection) else {
                break
            }

            if model.selectedCollection.wrappedValue == collection {
                if index - 1 >= 0 {
                    model.selectedCollection.wrappedValue = library.userCollections[index - 1]
                }
                else {
                    model.selectedCollection.wrappedValue = library.favourites
                }
            }

            library.userCollections.remove(at: index)
            break
        case .showInFinder:
            guard let url = collection.url else {
                break
            }

            NSWorkspace.shared.activateFileViewerSelecting([url])
            break
        }
    }
    
    /// Reset the currently selected collection to the default selection.
    func resetSelection() {
        model.selectedCollection.wrappedValue = library.soundfonts.first ?? library.favourites
    }
}

#Preview {
    @Previewable @State var selectedCollection: Collection?

    NavigationSplitView {
        SidebarView(selectedCollection: $selectedCollection)
            .environmentObject(Library(
                soundfonts: [
                    Collection("Soundfont 1", path: "/"),
                    Collection("Soundfont 2", path: "/"),
                ],
                favourites: Collection("Favourites", id: Collection.favouritesId),
                userCollections: [
                    Collection("Collection 1"),
                    Collection("Collection 2"),
                ]
            ))
    } detail: {
        Text(selectedCollection?.name ?? "nil")
    }
}
