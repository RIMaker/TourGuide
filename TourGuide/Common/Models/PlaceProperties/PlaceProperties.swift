//
//  PlaceProperties.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct PlaceProperties: Codable {
    let xid: String
    let name: String
    let address: Address
    let rate: String
    let osm: String
    let bbox: Bbox
    let wikidata: String
    let kinds: String
    let sources: Sources
    let otm: String
    let wikipedia: String
    let image: String
    let preview: Preview
    let wikipediaExtracts: WikipediaExtracts
    let point: Point
}
