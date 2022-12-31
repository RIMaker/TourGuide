//
//  Feature.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct Feature: Codable {
    let type: String?
    let id: String?
    let geometry: Geometry?
    let properties: Properties?
}
