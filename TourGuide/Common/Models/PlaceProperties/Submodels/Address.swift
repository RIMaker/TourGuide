//
//  Address.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct Address: Codable {
    let city: String?
    let state: String?
    let county: String?
    let country: String?
    let footway: String?
    let postcode: String?
    let countryCode: String?
    let cityDistrict: String?
}
