//
//  LibraryView.swift
//  Soundfonter
//
//  Created by marika on 2024-12-24.
//

import SwiftUI

struct LibraryView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var library: Library
    @State var model = ViewModel()
    
    @State var selectedCollection: Collection?
    @State var selectedInstrument: Instrument?
    
    // MARK: - View
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCollection: $selectedCollection)
        } detail: {
            if let selectedCollection {
                CollectionView(selectedCollection, selectedInstrument: $selectedInstrument) { instrument, action in
                    switch action {
                    case .addTo(let collection):
                        collection.instruments.append(instrument)
                        break
                    case .addToNewCollection:
                        let collection = Collection(instruments: [instrument])
                        library.userCollections.append(collection)
                        self.selectedCollection = collection
                        break
                    case .removeFrom(let collection):
                        collection.instruments.removeAll(where: { $0 == instrument })
                        if selectedInstrument == instrument {
                            selectedInstrument = nil
                        }
                        break
                    case .showInFinder:
                        NSWorkspace.shared.activateFileViewerSelecting([instrument.url])
                        break
                    }
                }
            }
        }
        .focusedSceneValue(\.selectedCollection, $selectedCollection)
        .focusedSceneValue(\.selectedInstrument, $selectedInstrument)
        .focusedSceneValue(\.libraryViewModel, model)
        .alert("Select Library", isPresented: $model.isShowingImportInfo) {
            Button("Select", role: .cancel) {
                model.advanceImportFlow()
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Please select the folder containing your sforzando library.")
        }
        .alert("Failed to Load Library", isPresented: $model.isShowingImportFailure) {
            Button("Select", role: .cancel) {
                model.advanceImportFlow()
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Library is invalid or malformed.")
        }
        .fileImporter(isPresented: $model.isShowingImportDialogue, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                do {
                    library.url = urls.first
                    try library.loadSoundfonts()
                    model.advanceImportFlow(result: .success)
                }
                catch {
                    print("\(error), \(model.importStatus)")
                    model.advanceImportFlow(result: .failure)
                    print(model.importStatus)
                }
                break
            case .failure(_):
                model.advanceImportFlow(result: .failure)
                break
            }
        } onCancellation: {
            model.advanceImportFlow()
        }
        .onAppear {
            // present the import flow if there is no library
            if library.url == nil {
                model.advanceImportFlow()
            }
            else {
                do {
                    try library.loadSoundfonts()
                }
                catch {
                    print("\(error), \(model.importStatus)")
                    model.importStatus = .failure
                }
            }
        }
        .onChange(of: library.url) { _, newValue in
            // dismiss the import flow if another window performs the import
            if newValue != nil {
                model.importStatus = .idle
            }
        }
    }
}

#Preview {
    let instruments = [
        Instrument(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/0/000_Instrument_0.sfz"),
        Instrument(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/5/005_Instru.ment_1.sfz"),
        Instrument(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/15/500_Instrument_2.sfz"),
        Instrument(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/199/090_Instrument_Spaces_3.sfz"),
        Instrument(path: "/Instruments/ARIAConverted/sf2/Collection_sf2/999/999_Instrument_-_4.sfz"),
    ]
    
    LibraryView()
        .environmentObject(Library(
            soundfonts: [
                Collection("Soundfont 1", instruments: instruments.shuffled()),
                Collection("Soundfont 2", instruments: instruments.shuffled()),
            ],
            favourites: Collection("Favourites", instruments: instruments.shuffled()),
            userCollections: [
                Collection("Collection 1", instruments: instruments.shuffled()),
                Collection("Collection 2", instruments: instruments.shuffled()),
            ]
        ))
}
