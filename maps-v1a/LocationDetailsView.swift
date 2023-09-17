//
//  LocationDetailsView.swift
//  maps-v1a
//
//  Created by Willian Santos on 9/17/23.
//

import SwiftUI
import MapKit

struct LocationDetailsView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @Binding var getDirections: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(mapSelection?.placemark.name ?? "")
                        .padding(.leading, 10)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .padding(.leading, 10)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        .padding(.trailing)
                }
                
                Spacer()
                
                Button {
                    show.toggle()
                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            } else {
                ContentUnavailableView("Sem Imagem do Lugar", systemImage: "eye.slash")
            }
            
            
            HStack(spacing: 24){
                Button {
                    if let mapSelection {
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Abrir no Mapa")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(.green)
                        .cornerRadius(12, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
                
                Button {
                    getDirections = true
                    show = false
                } label: {
                    Text("Fazer a Rota")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(.blue)
                        .cornerRadius(12, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                }
            }
            .padding(.horizontal)
        }
   
        
        .onAppear {
            fetchLookAroundPreview()
        }
        
        .onChange(of: mapSelection) {
            oldValue, newVlue in
            fetchLookAroundPreview()
        }
    }
}

extension LocationDetailsView {
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailsView(//
        mapSelection: .constant(nil)
      , show: .constant(false)
      , getDirections: .constant(false))
}
