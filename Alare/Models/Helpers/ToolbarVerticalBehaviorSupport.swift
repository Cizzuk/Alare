//
//  ToolbarVerticalBehaviorSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/09/26.
//

import SwiftUI

extension View {
    func toolbarVerticalBehaviorDisableIfAvailable() -> some View {
        if #available(iOS 27.1, *) {
            return self
                .toolbarVerticalBehavior(.disabled)
        } else {
            return self
        }
    }
}

