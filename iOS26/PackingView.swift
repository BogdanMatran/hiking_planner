//
//  PackingView.swift
//  iOS26
//
//  Created by Matran Bogdan on 12.06.2025.
//

import SwiftUI

struct PackingItem: Identifiable {
    let id = UUID()
    let name: String
    var isPacked: Bool = false
}

struct PackingView: View {
    @State private var items: [PackingItem] = [
        PackingItem(name: "Backpack"),
        PackingItem(name: "Water Bottle"),
        PackingItem(name: "Snacks"),
        PackingItem(name: "Map or GPS"),
        PackingItem(name: "First Aid Kit"),
        PackingItem(name: "Multi-tool or Knife"),
        PackingItem(name: "Flashlight or Headlamp"),
        PackingItem(name: "Rain Jacket"),
        PackingItem(name: "Sunscreen"),
        PackingItem(name: "Hiking Boots")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($items) { $item in
                    HStack {
                        Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isPacked ? .green : .secondary)
                            .onTapGesture {
                                item.isPacked.toggle()
                            }
                        Text(item.name)
                            .strikethrough(item.isPacked, color: .gray)
                            .foregroundStyle(item.isPacked ? .secondary : .primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Packing List")
        }
    }
}
