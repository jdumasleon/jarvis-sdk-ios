//
//  Item.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
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
