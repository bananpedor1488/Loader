//
//  Item.swift
//  Loader
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var timestamp: Date

    init(timestamp: Date, id: UUID = UUID()) {
        self.id = id
        self.timestamp = timestamp
    }
}
