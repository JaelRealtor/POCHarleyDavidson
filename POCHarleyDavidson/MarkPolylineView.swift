//
//  MarkPolylineView.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 11/02/25.
//

import Foundation
import MapKit
import SwiftUI

struct MapPolylineView: UIViewRepresentable {
    let polyline: MKPolyline
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addOverlay(polyline)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

class Coordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .orange
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
