//
//  SoundfonterApp.swift
//  Soundfonter
//
//  Created by marika on 2024-12-23.
//

import SwiftUI
import SwiftData

@main
struct SoundfonterApp: App {
    
    // MARK: - Properties
    
    /// The container used for data persistence within this app.
    let modelContainer: ModelContainer
    
    /// The library that this app is managing.
    var library: Library {
        return try! modelContainer.mainContext.fetch(FetchDescriptor<Library>()).first!
    }
    
    // MARK: - View
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
        }
        .modelContainer(modelContainer)
        .commands {
            SidebarCommands()
            
            CommandGroup(after: .newItem) {
                Button("New Collection") {
                    
                }
                .keyboardShortcut("n", modifiers: [.option, .command])
            }
            
            LibraryCommands(library: library)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        do {
            self.modelContainer = try ModelContainer(for: Library.self)
            
            // ensure there is always a library
            let count = try modelContainer.mainContext.fetchCount(FetchDescriptor<Library>())
            if count == 0 {
                modelContainer.mainContext.insert(Library())
            }
        }
        catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
}
