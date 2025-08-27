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
    
    @State private var aiPrompt = ""
    @State private var aiResponse = ""
    @State private var isGenerating = false
    @State var session = LanguageModelSession {
            """
             You are a hiking planner and will provide a hike in the desired area. You must include name of the hike, distance, elevation, stops and gear needed.
            """
        }
    var body: some View {
           NavigationStack {
               ScrollView {
                   VStack(alignment: .leading, spacing: 40) {
                       switch SystemLanguageModel.default.availability {
                       case .available:
                           // Show chat UI
                           HStack {
                               Image(systemName: "apple.intelligence")
                                   .symbolRenderingMode(.multicolor)
                                   .font(.subheadline)
                               Text("You can ask AI or browse the map")
                                   .font(.subheadline)
                                   .foregroundStyle(.secondary)
                           }
                           .padding(.horizontal)
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
                      
                       
                       // Searchable field, focused on appear
                       TextField("Search", text: $searchString)
                           .focused($isFocused)
                           .textFieldStyle(.roundedBorder)
                           .padding(.horizontal)
                           .onSubmit {
                               Task {
                                   await handleSearch()
                               }
                           }
                           .onAppear {
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                   isFocused = true
                               }
                           }

                       if isGenerating {
                           ProgressView("Generating hike plan…")
                               .padding(.horizontal)
                       } else if !aiResponse.isEmpty {
                           Text(aiResponse)
                               .font(.body)
                               .padding(.horizontal)
                       }

                       Map(position: $cameraPosition) {
                           // Add annotation later if needed
                       }
                       .clipShape(RoundedRectangle(cornerRadius: 12))
                       .frame(height: 250)
                       .padding(.horizontal)
                       
                       Spacer()
                   }
                   .padding(.vertical)
               }
           }
           .navigationTitle("Plan your hike")
       }
   
    
// MARK: - AI Call
    func handleSearch() async {
        do {
            isGenerating = true
            let response = try await session.respond(to: searchString)
            aiResponse = response.content
        } catch {
            aiResponse = "AI features are not available or permission denied."
        }
        isGenerating = false
    }
}

#Preview {
    ContentView()
}
