//
//  Address.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct Address: Codable {
    let city: String?
    let road: String?
    let state: String?
    let county: String?
    let suburb: String?
    let country: String?
    let footway: String?
    let postcode: String?
    let countryCode: String?
    let houseNumber: String?
    let cityDistrict: String?
}
