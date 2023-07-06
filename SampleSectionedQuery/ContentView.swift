//
//  ContentView.swift
//  SampleSectionedQuery
//
//  Created by Chuck Hartman on 6/9/23.
//

import SwiftUI
import SwiftData
import SectionedQuery

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // This @SectionedQuery's sectionIdentifier and sortDescriptors are coordinated so that
    // each "section" corresponds to an Item object and are all sorted by the Item's "order" property.
    // Then within each section, the Item's Attributes are shown in order by the Attribute's "order" property.
    
    @SectionedQuery(sectionIdentifier: \Attribute.item.name,
                    sortDescriptors: [SortDescriptor(\Attribute.item.order, order: .forward),
                                      SortDescriptor(\Attribute.order, order: .forward)],
                    predicate: nil,
                    animation: .default)
    private var sections
    
    private var didSave =  NotificationCenter.default.publisher(for: ModelContext.didSave)
    
    var body: some View {
        
        List {
            ForEach(self.sections) { section in
                Section(header: Text("Section for Item '\(section.id)'")) {
                    ForEach(section, id: \.self) { attribute in
                        Text("Item[\(attribute.item.order)] '\(attribute.item.name)' Attribute[\(attribute.order)]")
                            .monospaced()
                    }
                }
            }
        }
        // This is here to try to see when real ModelContext.didSave notifications start occuring
        .onReceive(self.didSave, perform: { notification in print("**** onReceive \(notification.name.rawValue)") } )
        Spacer()
        HStack {
            Button("Load", action: { self.load() } )
            Button("Swap", action: { self.swap() } )
            Button("Item Sort", action: { self.toggleItemSort() } )
            Button("Filter Attributes", action: { self.toggleAttributeFilter() } )
        }
        .buttonStyle(.bordered)
    }
    
    @MainActor private func load() {
        do {
            let itemDescriptor = FetchDescriptor<Item>()
            let items = try self.modelContext.fetch(itemDescriptor)
            for item in items {
                self.modelContext.delete(item)
            }
            try self.modelContext.save()
            
            let fetchDescriptor = FetchDescriptor<Attribute>()
            let attributes = try self.modelContext.fetch(fetchDescriptor)
            for item in attributes {
                self.modelContext.delete(item)
            }
            try self.modelContext.save()
            
            let item1 = Item(name: "Z", order: 0)
            self.modelContext.insert(Attribute(item: item1, name: "\(item1.name).0", order: 0))
            self.modelContext.insert(Attribute(item: item1, name: "\(item1.name).1", order: 1))
            self.modelContext.insert(Attribute(item: item1, name: "\(item1.name).2", order: 2))
            self.modelContext.insert(item1)
            
            let item2 = Item(name: "Y", order: 1)
            self.modelContext.insert(Attribute(item: item2, name: "\(item2.name).0", order: 0))
            self.modelContext.insert(Attribute(item: item2, name: "\(item2.name).1", order: 1))
            self.modelContext.insert(Attribute(item: item2, name: "\(item2.name).2", order: 2))
            self.modelContext.insert(item2)
            
            let item3 = Item(name: "X", order: 2)
            self.modelContext.insert(Attribute(item: item3, name: "\(item3.name).0", order: 0))
            self.modelContext.insert(Attribute(item: item3, name: "\(item3.name).1", order: 1))
            self.modelContext.insert(Attribute(item: item3, name: "\(item3.name).2", order: 2))
            self.modelContext.insert(item2)
            
            try self.modelContext.save()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    @MainActor private func swap() {
        // This will swap the order properties of the first two Items.
        do {
            let fetchDescriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\Item.order)])
            let items = try self.modelContext.fetch(fetchDescriptor)
            
            let firstItemOrder = items[0].order
            let secondItemOrder = items[1].order
            items[0].order = secondItemOrder
            items[1].order = firstItemOrder
            
            try self.modelContext.save()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    @MainActor private func toggleItemSort() {
        // This will toggle the Item's SortDescriptor between .forward and .reverse
        let oldItemOrder = self.sections.sortDescriptors[0].order
        let newItemOrder = oldItemOrder == SortOrder.forward ? SortOrder.reverse : SortOrder.forward
        
        self.sections.sortDescriptors = [SortDescriptor(\Attribute.item.order, order: newItemOrder),
                                         SortDescriptor(\Attribute.order, order: .forward)]
    }
    
    @MainActor private func toggleAttributeFilter() {
        // This will alternate between showing all Attributes and only the first Attribute of each Item
        if self.sections.predicate == nil {
            self.sections.predicate = #Predicate<Attribute> { attribute in attribute.order == 0 }
        } else {
            self.sections.predicate = nil
        }
    }
    
}

#Preview {
    // Workaround from: https://developer.apple.com/forums/thread/731320
    MainActor.assumeIsolated {
        ContentView()
            .modelContainer(for: [Item.self, Attribute.self], inMemory: true)
    }
}
