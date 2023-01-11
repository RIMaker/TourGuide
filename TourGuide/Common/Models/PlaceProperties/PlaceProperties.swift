//
//  PlaceProperties.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 17.12.2022.
//

import Foundation

struct PlaceProperties: Codable {
    let xid: String?
    let name: String
    let address: Address?
    let rate: String?
    let osm: String?
    let bbox: Bbox?
    let wikidata: String?
    let kinds: String?
    let sources: Sources?
    let otm: String?
    let wikipedia: String?
    let image: String?
    let preview: Preview?
    let wikipediaExtracts: WikipediaExtracts?
    let point: Point?
    
    func getAddress(type: AddressType) -> String {
        var addressArr: [String]
        switch type {
        case .full:
            addressArr = [address?.city ?? "", address?.road ?? "", address?.houseNumber ?? ""]
        case .short:
            addressArr = [address?.road ?? "", address?.houseNumber ?? ""]
        }
        addressArr = addressArr.filter { $0 != "" }
        return addressArr.joined(separator: ", ")
    }
}

enum AddressType {
    case full
    case short
}
