//
//  Item.swift
//  SampleSectionedQuery
//
//  Created by Chuck Hartman on 6/9/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    
    var name: String
    var order: Int
    @Relationship(.cascade) var attributes: [Attribute] = []
    
    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }
}
