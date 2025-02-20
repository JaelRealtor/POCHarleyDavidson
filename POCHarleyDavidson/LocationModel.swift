//
//  LocationModel.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 11/02/25.
//

import Foundation
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
