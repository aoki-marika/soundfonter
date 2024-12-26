//
//  LibraryView.swift
//  Soundfonter
//
//  Created by marika on 2024-12-24.
//

import SwiftUI

extension LibraryView {
    
    @Observable
    class ViewModel {
        
        // MARK: - Properties
        
        /// The current status of the view's library import flow.
        var importStatus = ImportStatus.idle {
            didSet {
                isShowingImportInfo = importStatus == .info
                isShowingImportDialogue = importStatus == .importing
                isShowingImportFailure = importStatus == .failure
            }
        }
        
        /// Whether to display the library import information dialogue or not.
        var isShowingImportInfo = false
        
        /// Whether to display the library import file selection dialogue or not.
        var isShowingImportDialogue = false
        
        /// Whether to display the library import error dialogue or not.
        var isShowingImportFailure = false
        
        // MARK: - Methods
        
        /// Advance the views library import flow to the next stage.
        func advanceImportFlow(result: ImportStatus? = nil) {
            switch importStatus {
            case .idle:
                importStatus = .info
                break
            case .info:
                importStatus = .importing
                break
            case .importing:
                guard let result else {
                    importStatus = .info
                    break
                }
                
                importStatus = result
                break
            case .failure:
                importStatus = .importing
                break
            default:
                break
            }
        }
        
        // MARK: - Enumerations
        
        /// The current status of the view's import flow.
        enum ImportStatus: Equatable {
            case idle
            case info
            case importing
            case failure
            case success
        }
    }
}

// MARK: - Extensions

extension FocusedValues {
    struct FocusedSelectedCollectionKey: FocusedValueKey {
        typealias Value = Binding<Collection?>
    }

    struct FocusedSelectedInstrumentKey: FocusedValueKey {
        typealias Value = Binding<Instrument?>
    }
    
    struct FocusedLibraryViewModelKey: FocusedValueKey {
        typealias Value = LibraryView.ViewModel
    }

    var selectedCollection: Binding<Collection?>? {
        get { self[FocusedSelectedCollectionKey.self] }
        set { self[FocusedSelectedCollectionKey.self] = newValue }
    }
    
    var selectedInstrument: Binding<Instrument?>? {
        get { self[FocusedSelectedInstrumentKey.self] }
        set { self[FocusedSelectedInstrumentKey.self] = newValue }
    }
    
    var libraryViewModel: LibraryView.ViewModel? {
        get { self[FocusedLibraryViewModelKey.self] }
        set { self[FocusedLibraryViewModelKey.self] = newValue }
    }
}
