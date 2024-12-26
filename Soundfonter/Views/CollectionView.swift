//
//  CollectionView.swift
//  Soundfonter
//
//  Created by marika on 2024-12-24.
//

import SwiftUI

struct CollectionView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var library: Library
    @ObservedObject var model: ViewModel
    
    /// Whether or not the user is currently entering a search query.
    @State var isSearching = false
    
    /// The currently entered search query.
    @State var filter = ""
    
    // MARK: - View
    
    var body: some View {
        Table(of: Instrument.self, selection: model.selectedInstrumentId) {
            TableColumn("Name") { soundfont in
                Text(soundfont.name)
            }
            
            TableColumn("#") { soundfont in
                Text("\(soundfont.number)")
            }
            .width(min: 40, ideal: 40, max: 60)
            
            TableColumn("Bank") { soundfont in
                Text("\(soundfont.bank)")
            }
            .width(min: 40, ideal: 40, max: 60)
        } rows: {
            ForEach(model.getFilteredInstruments(with: filter)) { instrument in
                TableRow(instrument)
                    .draggable(instrument)
                    .contextMenu {
                        Button("Show in Finder") {
                            model.perform(action: .showInFinder, instrument: instrument)
                        }

                        Divider()
                        
                        model.buildFavouriteMenu(for: instrument, in: library)
                        model.buildUserCollectionMenu(for: instrument, in: library)
                    }
            }
        }
        .navigationTitle(model.collection.name)
        .searchable(text: $filter, isPresented: $isSearching)
        .focusedSceneValue(\.isSearching, $isSearching)
        .focusedSceneValue(\.collectionViewModel, model)
        .toolbar {
            Group {
                let instrument = model.selectedInstrument.wrappedValue
                model.buildFavouriteMenu(for: instrument, in: library)
                model.buildUserCollectionMenu(for: instrument, in: library)
            }
            .disabled(model.selectedInstrument.wrappedValue == nil)
        }
        .onChange(of: model.collection) { _, _ in
            // reset selection when view changes
            model.selectedInstrument.wrappedValue = nil
        }
    }
    
    // MARK: - Initializers
    
    init(_ collection: Collection, selectedInstrument: Binding<Instrument?>, actionCallback: @escaping (Instrument, Action) -> Void) {
        self.model = ViewModel(collection: collection, selectedInstrument: selectedInstrument, actionCallback: actionCallback)
    }
}

#Preview {
    @Previewable @State var selectedInstrument: Instrument? = .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/199/090_Instrument_Spaces_3.sfz")
    @Previewable @State var lastInstrument: Instrument?
    @Previewable @State var lastAction: CollectionView.Action?
    
    let collection = Collection("Collection", instruments: [
        .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/0/000_Instrument_0.sfz"),
        .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/5/005_Instru.ment_1.sfz"),
        .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/15/500_Instrument_2.sfz"),
        .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/199/090_Instrument_Spaces_3.sfz"),
        .init(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/999/999_Instrument_-_4.sfz"),
    ])
    
    Group {
        CollectionView(collection, selectedInstrument: $selectedInstrument) {
            lastInstrument = $0
            lastAction = $1
        }
        .environmentObject(Library(
            soundfonts: [
                Collection("Soundfont 1"),
                Collection("Soundfont 2"),
            ],
            favourites: Collection("Favourites"),
            userCollections: [
                Collection("Collection 1"),
                Collection("Collection 2"),
            ]
        ))
        
        Text("Selected: \(selectedInstrument?.name ?? "nil")")
        if let lastInstrument, let lastAction {
            Text("\(lastInstrument.name): \(lastAction)")
        }
        else {
            Text("nil: nil")
        }
    }
}
