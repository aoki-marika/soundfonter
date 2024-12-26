//
//  CollectionRow.swift
//  Soundfonter
//
//  Created by marika on 2024-12-25.
//

import SwiftUI

struct CollectionRow: View {
    
    // MARK: - Properties
    
    @State var model: ViewModel
    
    // MARK: - View
    
    var body: some View {
        Group {
            if model.collection.url == nil && !model.collection.isFavourites {
                Label {
                    TextField("Name", text: $model.collection.name)
                } icon: {
                    Image(systemName: model.icon)
                }
            }
            else {
                Label(model.collection.name, systemImage: model.icon)
            }
        }
        .tag(model.collection)
        .if(model.collection.url == nil) {
            $0.dropDestination(for: Instrument.self) { instruments, _ in
                // cancel the drag if any instruments are already in this collection
                if instruments.contains(where: {
                    model.collection.instruments.contains($0)
                }) {
                    return false
                }
                
                for instrument in instruments {
                    self.model.collection.instruments.append(instrument)
                }

                return true
            }
        }
        .contextMenu {
            if model.collection.url != nil {
                Button("Show in Finder") {
                    model.perform(action: .showInFinder)
                }
            }
            else if !model.collection.isFavourites {
                Button("Delete", role: .destructive) {
                    model.perform(action: .delete)
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    init(_ collection: Collection, action: @escaping (Collection, Action) -> Void) {
        self.model = ViewModel(collection: collection, actionCallback: action)
    }
}

#Preview {
    @Previewable @State var lastCollection: Collection?
    @Previewable @State var lastAction: CollectionRow.Action?
    
    let action: (Collection, CollectionRow.Action) -> Void = {
        lastCollection = $0
        lastAction = $1
    }
    
    List {
        CollectionRow(Collection("Collection 1"), action: action)
        CollectionRow(Collection("Collection 2"), action: action)
        CollectionRow(Collection("Soundfont", url: URL(filePath: "/")), action: action)
        CollectionRow(Collection("Favourites", id: Collection.favouritesId), action: action)
        
        Divider()
        
        if let lastCollection, let lastAction {
            Text("\(lastCollection.name): \(lastAction)")
        }
        else {
            Text("nil")
        }
    }
    .listStyle(.sidebar)
}
