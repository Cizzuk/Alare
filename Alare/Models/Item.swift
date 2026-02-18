//
//  Item.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/18.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
