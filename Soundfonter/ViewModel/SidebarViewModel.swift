//
//  SidebarViewModel.swift
//  Soundfonter
//
//  Created by marika on 2024-12-25.
//

import SwiftUI
import Combine

extension SidebarView {
    
    @Observable
    class ViewModel {
        
        // MARK: - Properties

        /// The currently selected collection within the view.
        let selectedCollection: Binding<Collection?>
        
        // MARK: - Initializers
        
        init(selectedCollection: Binding<Collection?>) {
            self.selectedCollection = selectedCollection
        }
    }
}
