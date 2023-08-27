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
    
    var item: Item?
    
    var name: String
    var order: Int

    init(item: Item, name: String, order: Int) {
        self.name = name
        self.order = order
        
        self.item = item    // With Xcode Beta 7, this will crash if set before name and/or order.
    }
}
