//
//  Attribute.swift
//  SampleSectionedQuery
//
//  Created by Chuck Hartman on 6/9/23.
//

import Foundation
import SwiftData

@Model
final class Attribute {
    
    @Relationship var item: Item
    var name: String
    var order: Int

    init(item: Item, name: String, order: Int) {
        self.item = item
        self.name = name
        self.order = order
    }
}
