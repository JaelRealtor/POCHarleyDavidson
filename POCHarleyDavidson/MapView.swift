//
//  MapView.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 10/02/25.
//
import Foundation
import MapKit
import SwiftUI

struct MapView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 32.7157, longitude: -117.1611),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var locations: [LocationModel] = []
    @State private var distance: Double = 0.0
    @State private var message = ""
    @State private var halfPointReached = false
    @State private var showingAlert = false
    @State private var userLocation = CLLocationCoordinate2D(latitude: 32.7157, longitude: -117.1611)
    
    
    @State private var midDistance: Double = 0.0
    @State private var isMoving = false
    @State private var lookAroundScene: MKLookAroundScene?
    let stories = Array(1...10)
    
    var body: some View {
        VStack(spacing:0) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stories, id: \.self) { _ in
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
            }
            
            ZStack{
                Map(coordinateRegion: $region, annotationItems: [LocationModel(coordinate: userLocation)]) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    }
                }
                .frame(maxWidth: .infinity,
                       maxHeight: UIScreen.main.bounds.height * 0.40)
            }
         
            
          
            VStack(spacing: 12) {
                Button(action: calculateRoute) {
                    Text("Calculate Route")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: startMovingUser) {
                    Text(isMoving ? "Moving..." : "Start Moving")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMoving ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isMoving)
            }
            .padding()
            
            VStack(spacing: 5) {
                Text("Total Distance: \(distance, specifier: "%.2f") km")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Halfway: \(midDistance, specifier: "%.2f") km")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
        
            
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("¡Halfway there!"),
                    message: Text(message),
                    dismissButton: .default(
                        Text("Acept"),
                        action: {isMoving = false})
                )
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func calculateRoute() {
        let end = CLLocationCoordinate2D(latitude: 32.6783, longitude: -115.4989) // Calexico
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            self.distance = route.distance / 1000 // Convertir a km
            self.locations = [
                LocationModel(coordinate: userLocation),
                LocationModel(coordinate: end)
            ]
            
            let polylineRect = route.polyline.boundingMapRect
            
            Task {
                self.region = MKCoordinateRegion(polylineRect)
            }
            
    
            midDistance = route.distance / 2000
        }
    }

    func startMovingUser() {
        guard !isMoving else { return }

        isMoving = true
        var startPoint = userLocation
        let end = CLLocationCoordinate2D(latitude: 32.6783, longitude: -115.4989)

  
        let totalDistance = haversineDistance(from: CLLocation(latitude: startPoint.latitude, longitude: startPoint.longitude),
                                              to: CLLocation(latitude: end.latitude, longitude: end.longitude))
        midDistance = totalDistance / 2

        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

        Task {
            while isMoving {
                startPoint.latitude += (end.latitude - startPoint.latitude) * 0.05
                startPoint.longitude += (end.longitude - startPoint.longitude) * 0.05

                region.center = startPoint
                userLocation = startPoint

 
                let currentDistance = haversineDistance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude),
                                                        to: CLLocation(latitude: end.latitude, longitude: end.longitude))

     
                if currentDistance <= midDistance && !halfPointReached {
                    halfPointReached = true
                    message = "¡Has llegado a la mitad del recorrido!"

                    await MainActor.run {
                        showingAlert = true
                        isMoving = false
                    }
                    return
                }

                try? await Task.sleep(nanoseconds: 300_000_000)

                if !isMoving { break }
            }
        }
    }

    func haversineDistance(from: CLLocation, to: CLLocation) -> Double {
        let lat1 = from.coordinate.latitude * .pi / 180
        let lon1 = from.coordinate.longitude * .pi / 180
        let lat2 = to.coordinate.latitude * .pi / 180
        let lon2 = to.coordinate.longitude * .pi / 180
        
        let dlat = lat2 - lat1
        let dlon = lon2 - lon1
        
        let a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let radius = 6371.0
        return radius * c
    }
    
    func midpointCoordinate(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat1 = start.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let lon2 = end.longitude * .pi / 180
        
        let dlon = lon2 - lon1
        
        let bx = cos(lat2) * cos(dlon)
        let by = cos(lat2) * sin(dlon)
        
        let latMid = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by))
        let lonMid = lon1 + atan2(by, cos(lat1) + bx)
        
        return CLLocationCoordinate2D(latitude: latMid * 180 / .pi, longitude: lonMid * 180 / .pi)
    }
}

#Preview {
    MapView()
}
