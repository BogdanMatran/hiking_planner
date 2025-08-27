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
    @Binding var items: [PackingItem]

    var body: some View {
        NavigationStack {
            if items.isEmpty {
                Text("Please ask AI to create a hike and then you can find the packing list here")
            }
            List {
                ForEach($items) { $item in
                    HStack {
                        Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isPacked ? .green : .secondary)
                            .onTapGesture {
                                item.isPacked.toggle()
                                let itemId = item.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // Remove the actual item from the array
                                    if let index = items.firstIndex(where: { $0.id == itemId }) {
                                        items.remove(at: index)
                                    }
                                }
                            }
                        Text(item.name)
                            .strikethrough(item.isPacked, color: .gray)
                            .foregroundStyle(item.isPacked ? .secondary : .primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onAppear()
            .listStyle(.plain)
            .navigationTitle("Packing List")
        }
    }
}

