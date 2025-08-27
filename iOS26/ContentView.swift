//
//  ContentView.swift
//  iOS26
//
//  Created by Matran Bogdan on 12.06.2025.
//

import SwiftUI
import MapKit
import FoundationModels

struct ContentView: View {
    @State private var searchString: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @Namespace var glassEffectNamespace
    @State private var showAddRoute = false
    @State private var hikes = sampleHikes
    var body: some View {
        TabView {
            Tab("Routes", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath") {
                NavigationStack {
                    RoutesView()
                        .toolbar {
                            // Leading button
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showAddRoute = true
                                } label: {
                                    Image(systemName: "plus")
                                        .glassEffectUnion(id: 1, namespace: glassEffectNamespace)
                                }

                            }
                        }
                        .sheet(isPresented: $showAddRoute) {
                            AddHikeRouteView { newHike in
                                hikes.append(newHike)
                            }
                        }
                }
            }
            
            Tab("Packing", systemImage: "backpack.fill") {
                PackingView()
            }

            Tab(role: .search) {
              NavigationStack {
                    SearchContentView(searchString: $searchString)
                }
            }
        }
        .searchable(text: $searchString, prompt: "Search")
        .searchToolbarBehavior(.minimize)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.teal)
       
    }
}

struct AccountView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct StartView: View {
    var body: some View {
        Text("Hello, Start!")
    }
}

struct SearchContentView: View {
    @FocusState private var isFocused: Bool
    @Binding var searchString: String
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.8651, longitude: -119.5383),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    
    @State private var aiResponse = ""
    @State private var isGenerating = false
    @State private var parsedHike: Hike?
    
    @State var session = LanguageModelSession {
        """
        Task: Generate a hiking route in structured text. 
        Always reply in this format only:

        Name: [Hike Name], 
        Distance: [Distance in miles], 
        Elevation: [Elevation in feet], 
        Stops: [Stop1, Stop2], 
        Gear: [Gear1, Gear2], 
        Coordinates: [latitude, longitude]

        Example:
        Name: Yosemite Falls Trail, Distance: 7.6 miles, Elevation: 2600 ft, Stops: [Lower Falls, Upper Falls], Gear: [Hiking shoes, Water, Snacks], Coordinates: [37.756, -119.596]
        """
    }

    
    let hikeGenerator = HikeGenerator()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // Status / availability
                    switch SystemLanguageModel.default.availability {
                    case .available:
                        HStack {
                            Image(systemName: "apple.intelligence")
                                .symbolRenderingMode(.multicolor)
                                .font(.title3)
                                .padding(.horizontal)
                            TextField("Ask AI about a hike...", text: $searchString)
                                .font(.custom("IBM Plex Mono", size: 18))
                                .foregroundColor(.primary)
                                .focused($isFocused)
                                .onSubmit {
                                    Task { await handleSearch() }
                                }
                                .disabled(session.isResponding)
                            
                            if !searchString.isEmpty {
                                Button {
                                    Task { await handleSearch() }
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.title2)
                                        .padding(.horizontal)
                                }
                                .disabled(session.isResponding)
                            }
                        }
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial) // glassy AI-like background
                        .clipShape(Capsule())
                        .shadow(radius: 2, y: 1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                        .onAppear {
                            session.prewarm()
                        }
                    case .unavailable(let reason):
                        let text = switch reason {
                        case .appleIntelligenceNotEnabled:
                            "Apple Intelligence is not enabled. Please enable it in Settings."
                        case .deviceNotEligible:
                            "This device is not eligible for Apple Intelligence. Please use a compatible device."
                        case .modelNotReady:
                            "The language model is not ready yet. Please try again later."
                        @unknown default:
                            "The language model is unavailable for an unknown reason."
                        }
                        ContentUnavailableView(text, systemImage: "apple.intelligence.badge.xmark")
                    }
                 
                    if isGenerating {
                        ProgressView("Generating hike plan…")
                            .padding(.horizontal)
                    }
                    
                    // Show parsed hike or fallback to raw response
                    if let hike = parsedHike {
                        VStack(alignment: .leading, spacing: 20) {
                            // Hike name as a headline in AI style
                            Text(hike.name)
                                .font(.custom("IBM Plex Mono", size: 22))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Distance", systemImage: "ruler")
                                    .font(.custom("IBM Plex Mono", size: 14))
                                    .foregroundStyle(.secondary)
                                Text(hike.distance)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.primary)
                                
                                Label("Elevation", systemImage: "arrow.up.right")
                                    .font(.custom("IBM Plex Mono", size: 14))
                                    .foregroundStyle(.secondary)
                                Text(hike.elevation)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.primary)
                            }
                            
                            if !hike.stops.isEmpty {
                                Text("Stops:")
                                    .font(.custom("IBM Plex Mono", size: 16))
                                    .foregroundColor(.primary)
                                ForEach(hike.stops, id: \.self) { stop in
                                    Text("• \(stop)")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if !hike.gearNeeded.isEmpty {
                                Text("Gear Needed:")
                                    .font(.custom("IBM Plex Mono", size: 16))
                                    .foregroundColor(.primary)
                                ForEach(hike.gearNeeded, id: \.self) { gear in
                                    Text("• \(gear)")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial) // glassy AI card
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 4, y: 2)
                        
                        Map(position: $cameraPosition) {
                            Marker(hike.name, coordinate: hike.coordinates)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(height: 250)
                        
                    } else if !aiResponse.isEmpty {
                        // fallback if parsing fails
                        Text(aiResponse)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Plan your hike")
    }
    
    // MARK: - AI Call
    func handleSearch() async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let response = try await session.respond(to: searchString)
            aiResponse = response.content
            parsedHike = hikeGenerator.parseHike(from: aiResponse)
            
            if let hike = parsedHike {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: hike.coordinates,
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                )
            }
            searchString = ""
        } catch {
            aiResponse = "AI features are not available or permission denied."
            parsedHike = nil
        }
    }
}


// Model for Hike Data
struct Hike: Identifiable {
    let id = UUID()
    var name: String
    var distance: String
    var elevation: String
    var stops: [String]
    var gearNeeded: [String]
    var coordinates: CLLocationCoordinate2D
}

// Create a Generable Tool
@MainActor
class HikeGenerator {
    
    // Parse the AI response into Hike details
    func parseHike(from response: String) -> Hike? {
        // "Name: [Hike Name], Distance: [Distance], Elevation: [Elevation], Stops: [Stop1, Stop2], Gear: [Gear1, Gear2], Coordinates: [Lat, Long]"
                
        let regexPattern = #"Name:\s*(.*?),\s*Distance:\s*(.*?),\s*Elevation:\s*(.*?),\s*Stops:\s*\[(.*?)\],\s*Gear:\s*\[(.*?)\],\s*Coordinates:\s*\[(.*?),(.*?)\]"#
        
        if let regex = try? NSRegularExpression(pattern: regexPattern, options: []) {
            let range = NSRange(location: 0, length: response.utf16.count)
            if let match = regex.firstMatch(in: response, options: [], range: range) {
                
                // Extract matched groups
                let name = String(response[Range(match.range(at: 1), in: response)!])
                let distance = String(response[Range(match.range(at: 2), in: response)!])
                let elevation = String(response[Range(match.range(at: 3), in: response)!])
                let stopsString = String(response[Range(match.range(at: 4), in: response)!])
                let gearString = String(response[Range(match.range(at: 5), in: response)!])
                let latitude = Double(String(response[Range(match.range(at: 6), in: response)!])) ?? 0.0
                let longitude = Double(String(response[Range(match.range(at: 7), in: response)!])) ?? 0.0
                
                // Convert Stops and Gear to arrays
                let stops = stopsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let gear = gearString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                
                // Return a Hike object
                return Hike(name: name, distance: distance, elevation: elevation, stops: stops, gearNeeded: gear, coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        return nil
    }
}
#Preview {
    ContentView()
}
