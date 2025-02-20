//
//  SocialMediaEventsView.swift
//  POCHarleyDavidson
//
//  Created by JaelWizeline on 11/02/25.
//

import SwiftUI

struct SocialMediaEventsView: View {
    
    let sections: [String: [String]] = [
        "Recent Events": (1...5).map { "photo\($0)" },
        "Participant Friends": (9...13).map { "photo\($0)" },
        "For You": (14...17).map { "photo\($0)" }
    ]
    
    let columnCount = 2

    func generateColumns(for images: [String]) -> [[String]] {
        var columns = Array(repeating: [String](), count: columnCount)
        for (index, image) in images.enumerated() {
            columns[index % columnCount].append(image)
        }
        return columns
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sections.keys.sorted(), id: \.self) { section in
                    if let images = sections[section] {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(10)
                                .padding(.horizontal)

                            let columns = generateColumns(for: images)

                            HStack(alignment: .top, spacing: 10) {
                                ForEach(columns, id: \.self) { column in
                                    VStack(spacing: 10) {
                                        ForEach(column, id: \.self) { image in
                                            Image(image)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .shadow(radius: 4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}


#Preview {
    SocialMediaEventsView()
}

