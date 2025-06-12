//
//  Routes.swift
//  iOS26
//
//  Created by Matran Bogdan on 12.06.2025.
//

import SwiftUI

struct HikeRoute: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let distance: Double // in kilometers
    let difficulty: String
}

let sampleHikes = [
    HikeRoute(name: "Sunset Peak Trail", location: "Yosemite, CA", distance: 7.2, difficulty: "Moderate"),
    HikeRoute(name: "Pine Ridge Loop", location: "Zion National Park, UT", distance: 10.5, difficulty: "Hard"),
    HikeRoute(name: "Riverwalk Trail", location: "Smoky Mountains, TN", distance: 4.3, difficulty: "Easy"),
    HikeRoute(name: "Bear Lake Loop", location: "Rocky Mountain, CO", distance: 3.1, difficulty: "Easy"),
    
    // Added hikes
    HikeRoute(name: "Angels Landing", location: "Zion National Park, UT", distance: 8.7, difficulty: "Hard"),
    HikeRoute(name: "Misty Mountain Trail", location: "Blue Ridge Mountains, NC", distance: 6.4, difficulty: "Moderate"),
    HikeRoute(name: "Cascade Pass", location: "North Cascades, WA", distance: 11.0, difficulty: "Moderate"),
    HikeRoute(name: "Skyline Trail", location: "Mount Rainier, WA", distance: 9.3, difficulty: "Hard"),
    HikeRoute(name: "Emerald Lake Trail", location: "Rocky Mountain, CO", distance: 5.1, difficulty: "Easy"),
    HikeRoute(name: "Kalalau Trail", location: "Kauai, HI", distance: 18.4, difficulty: "Hard"),
    HikeRoute(name: "Mount LeConte", location: "Smoky Mountains, TN", distance: 12.1, difficulty: "Hard"),
    HikeRoute(name: "Crater Lake Rim", location: "Crater Lake, OR", distance: 6.9, difficulty: "Moderate"),
    HikeRoute(name: "Hoh Rain Forest Trail", location: "Olympic National Park, WA", distance: 5.8, difficulty: "Easy"),
    HikeRoute(name: "Mount Diablo Summit", location: "Mount Diablo, CA", distance: 13.0, difficulty: "Hard")
]

struct RoutesView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(sampleHikes) { hike in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(hike.name)
                                .font(.headline)

                            Text(hike.location)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Label("\(hike.distance, specifier: "%.1f") km", systemImage: "figure.walk")
                                Spacer()
                                Text(hike.difficulty)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(colorForDifficulty(hike.difficulty))
                                    )
                            }
                            .font(.subheadline)
                        }
                        .padding()
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .navigationTitle("Hiking Routes")
        }
    }
}

func colorForDifficulty(_ difficulty: String) -> Color {
    switch difficulty.lowercased() {
    case "easy":
        return .green
    case "moderate":
        return .orange
    case "hard":
        return .red
    default:
        return .gray
    }
}
