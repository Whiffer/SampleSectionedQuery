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
    
    @State private var sectionByItem = true
    @State private var sortItemOrder = SortOrder.forward
    @State private var sortAttributeOrder = SortOrder.forward
    @State private var searchTerm = ""

    // This @SectionedQuery's sectionIdentifier and sortDescriptors are coordinated so that
    // each "section" corresponds to an Item object and are all sorted by the Item's "order" property.
    // Then within each section, the Item's Attributes are shown in order by the Attribute's "order" property.
    
    @SectionedQuery(sectionIdentifier: \Attribute.item!.name,
                    sortDescriptors: [SortDescriptor(\Attribute.item!.order, order: .forward),
                                      SortDescriptor(\Attribute.order, order: .forward)],
                    predicate: nil,
                    animation: .default)
    private var sections
    
    var body: some View {
        
        Text("Section by: \(self.sectionByItem ? "'Item.name'" : "'Attribute.name'")")
        Text("Item.order sort: \(self.sortItemOrder == .forward ? ".forward" : ".reverse")")
        Text("Attribute.order sort: \(self.sortAttributeOrder == .forward ? ".forward" : "reverse")")
        Text("Filter by Attribute.name's that contains: \(self.sections.predicate == nil ? "''" : "'\(self.searchTerm)'")")
        
        List {
            ForEach(self.sections) { section in
                Section(header: Text("Section for \(self.sectionByItem ? "Item" : "Attribute") '\(section.id)'")) {
                    ForEach(section, id: \.self) { attribute in
                        Text("Item[\(attribute.item!.order)] '\(attribute.item!.name)' Attribute[\(attribute.order)] '\(attribute.name)'")
                            .monospaced()
                    }
                }
            }
        }
        .searchable(text: self.$searchTerm)
        .onChange(of: self.searchTerm) { self.toggleSearchTermFilter() }
        
        Spacer()
        HStack {
            Button("(Re)load", action: { self.load() } )
            Button("Toggle Section by", action: { self.toggleSectionGrouping() } )
            Button("Toggle Item Sort", action: { self.toggleItemSort() } )
            Button("Toggle Attribute Sort", action: { self.toggleAttributeSort() } )
            Button("Swap first two Item names", action: { self.swap() } )
        }
        .buttonStyle(.bordered)
    }
    
    @MainActor private func load() {
        do {
            let fetchDescriptor = FetchDescriptor<Attribute>()
            let attributes = try self.modelContext.fetch(fetchDescriptor)
            for attribute in attributes {
                self.modelContext.delete(attribute)
            }
            try self.modelContext.save()

            let itemDescriptor = FetchDescriptor<Item>()
            let items = try self.modelContext.fetch(itemDescriptor)
            for item in items {
                self.modelContext.delete(item)
            }
            try self.modelContext.save()

            let item1 = Item(name: "Basketball", order: 0)
            self.modelContext.insert(item1)
            self.modelContext.insert(Attribute(item: item1, name: "Spherical", order: 0))
            self.modelContext.insert(Attribute(item: item1, name: "Hollow", order: 1))
            self.modelContext.insert(Attribute(item: item1, name: "Large", order: 2))

            let item2 = Item(name: "Football", order: 1)
            self.modelContext.insert(item2)
            self.modelContext.insert(Attribute(item: item2, name: "Oval", order: 0))
            self.modelContext.insert(Attribute(item: item2, name: "Hollow", order: 1))
            self.modelContext.insert(Attribute(item: item2, name: "Large", order: 2))

            let item3 = Item(name: "Baseball", order: 2)
            self.modelContext.insert(item3)
            self.modelContext.insert(Attribute(item: item3, name: "Spherical", order: 0))
            self.modelContext.insert(Attribute(item: item3, name: "Solid", order: 1))
            self.modelContext.insert(Attribute(item: item3, name: "Small", order: 2))

            try self.modelContext.save()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    @MainActor private func swap() {
        // This will swap the name properties of the first two ordered Items.
        do {
            let fetchDescriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\Item.order)])
            let items = try self.modelContext.fetch(fetchDescriptor)
            
            let firstItemName = items[0].name
            let secondItemName = items[1].name
            items[0].name = secondItemName
            items[1].name = firstItemName
            
            try self.modelContext.save()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    @MainActor private func toggleItemSort() {
        // This will toggle the Item's SortDescriptor between .forward and .reverse
        self.sortItemOrder = (self.sortItemOrder == .forward) ? .reverse : .forward
        self.setupSortingAndGrouping()
    }
    
    @MainActor private func toggleAttributeSort() {
        // This will toggle the Attribute's SortDescriptor between .forward and .reverse
        self.sortAttributeOrder = (self.sortAttributeOrder == .forward) ? .reverse : .forward
        self.setupSortingAndGrouping()
    }
    
    @MainActor private func toggleSearchTermFilter() {
        guard !self.searchTerm.isEmpty else {
            self.sections.predicate = nil
            return
        }
        
        // This will search for only those Attribute's with name's that contain the searchTerm as a substring
        self.sections.predicate = #Predicate<Attribute> { $0.name.localizedStandardContains(searchTerm) }
    }
    
    @MainActor private func toggleSectionGrouping() {
        // This will toggle between sectioning Attributes by their related Item and their own name property.
        self.sectionByItem.toggle()
        self.setupSortingAndGrouping()
    }
    
    private func setupSortingAndGrouping() {
        // Important Note: In each case, the sectionIdentifier is coordinated with the first SortDescriptor
        if self.sectionByItem {
            self.sections.sectionIdentifier = \Attribute.item!.name
            // Note: Items are sorted by their order property and not by their name property
            self.sections.sortDescriptors = [SortDescriptor(\Attribute.item!.order, order: sortItemOrder),
                                             SortDescriptor(\Attribute.order, order: sortAttributeOrder)]
        } else {
            self.sections.sectionIdentifier = \Attribute.name  // Note: sectionIdentifier must be a Sring
            self.sections.sortDescriptors = [SortDescriptor(\Attribute.name, order: sortAttributeOrder),
                                             SortDescriptor(\Attribute.item!.order, order: sortItemOrder)]
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
