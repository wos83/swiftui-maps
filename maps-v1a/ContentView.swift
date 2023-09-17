//
//  ContentView.swift
//  maps-v1a
//
//  Created by Willian Santos on 9/17/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaing = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            
            Annotation("Minha Localização", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/.opacity(0.25))
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
            }
            
            ForEach(results, id: \.self) {
                item in
                if routeDisplaing {
                    if item == routeDestination {
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                } else {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
            .overlay(alignment: .top) {
                TextField("Digite o que deseja buscar..", text: $searchText)
                    .font(.subheadline)
                    .padding(12)
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .opacity(0.75)
                    .padding()
            }
            
            .onSubmit(of: .text) {
                Task { await searchPlaces() }
            }
            
            .onChange(of: getDirections, {
                oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            })
            
            .onChange(of: mapSelection, {
                oldValue, newValue in
                showDetails = newValue != nil
            })
            
            .sheet(isPresented: $showDetails, content: {
                LocationDetailsView(mapSelection: $mapSelection,
                                    show: $showDetails,
                                    getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
            })
            
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
        }
    }

extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaing = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaing {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 40.730610, longitude: -74.005973) //New York
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
        latitudinalMeters: 15000,
        longitudinalMeters: 15000)
    }
}

#Preview {
    ContentView()
}
