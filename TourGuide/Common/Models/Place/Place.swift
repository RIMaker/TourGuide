//
//  Place.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct Place: Codable {
    let type: String
    let features: [Feature]
}
