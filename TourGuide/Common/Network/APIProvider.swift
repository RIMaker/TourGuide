//
//  APIProvider.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 01.11.2022.
//

import Foundation

struct APIProvider {
    
    static let shared: APIProvider = APIProvider()
    
    private let apiKey = "apikey=5ae2e3f221c38a28845f05b63ac031fb6aaefbbe2c28798dedc4facd"
    
    private let baseURL: String = "https://api.opentripmap.com/0.1/ru/places"
    
    private let listOfPlaces: String = "/bbox?lon_min=39.563311&lat_min=47.173234&lon_max=39.845400&lat_max=47.342596&kinds=interesting_places&format=geojson"
    
    private let propertiesOfObject: String = "/xid/"
    
    func placesURL() -> URL? {
        return URL(string: baseURL + listOfPlaces + "&" + apiKey)
    }
    
    func propertiesOfObjectURL(withId id: String) -> URL? {
        return URL(string: baseURL + propertiesOfObject + id + "?" + apiKey)
    }
}
