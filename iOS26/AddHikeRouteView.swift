//
//  File.swift
//  iOS26
//
//  Created by Matran Bogdan on 12.06.2025.
//

import SwiftUI

struct AddHikeRouteView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var distance: String = ""
    @State private var difficulty: String = "Easy"

    let onSave: (HikeRoute) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Route Info")) {
                    TextField("Trail Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Distance (km)", text: $distance)
                        .keyboardType(.decimalPad)
                    
                    Picker("Difficulty", selection: $difficulty) {
                            Text("Easy").tag("Easy")
                            Text("Moderate").tag("Moderate")
                            Text("Hard").tag("Hard")
                        }
                        .pickerStyle(.palette)
                        .padding(4)
                        .background(
                            LinearGradient(
                                colors: [.mint, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(Capsule())
                        )
                        .tint(.clear)
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("Add Hike")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let distanceValue = Double(distance), !name.isEmpty, !location.isEmpty {
                            let newRoute = HikeRoute(name: name, location: location, distance: distanceValue, difficulty: difficulty)
                            onSave(newRoute)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || location.isEmpty || Double(distance) == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
