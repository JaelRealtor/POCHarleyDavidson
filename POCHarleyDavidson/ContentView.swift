//
//  ContentView.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 10/02/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SocialMediaEventsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
            
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Mapa")
                }

        }
    }
}


#Preview {
    ContentView()
}
