//
//  ContentView.swift
//  iOS26
//
//  Created by Matran Bogdan on 12.06.2025.
//

import SwiftUI
import MapKit

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
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 40) {
                HStack {
                    Image(systemName: "apple.intelligence")
                        .symbolRenderingMode(.multicolor)
                        .font(.subheadline)
                    Text("You can ask AI or browse the map")
                        .searchable(text: $searchString, prompt: "Search")
                        .focused($isFocused)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                }
                .padding(.horizontal)
                // 🗺️ New Map with cameraPosition (iOS 17+)
                Map(position: $cameraPosition) {
                    // You can add annotations here if needed
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Plan your hike")
    }
}

#Preview {
    ContentView()
}
