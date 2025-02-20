//
//  LocationModel.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 11/02/25.
//

import Foundation
import CoreLocation

struct LocationModel: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
