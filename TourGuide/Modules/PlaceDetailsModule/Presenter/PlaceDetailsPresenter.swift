//
//  PlaceDetailPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import Foundation
import MapKit

protocol PlaceDetailsPresenterDelegate {
    func makeRoute()
}

protocol PlaceDetailsPresenter {
    var router: RouterPlaceDetailsScreen? { get }
    var placeProperties: PlaceProperties? { get }
    init(place: Feature?, userLocation: CLPlacemark?, networkManager: NetworkManager?, view: PlaceDetailsController?, router: RouterPlaceDetailsScreen?)
    func viewShown()
    func distanceToUser(fromPlace place: MKMapItem) -> String?
}

class PlaceDetailsPresenterImpl: PlaceDetailsPresenter {
    
    var router: RouterPlaceDetailsScreen?
    
    var placeProperties: PlaceProperties?
    
    private var place: Feature?
    
    private var userLocation: CLPlacemark?
    
    private var view: PlaceDetailsController?
    
    private var networkManager: NetworkManager?
    
    required init(place: Feature?, userLocation: CLPlacemark?, networkManager: NetworkManager?, view: PlaceDetailsController?, router: RouterPlaceDetailsScreen?) {
        self.place = place
        self.userLocation = userLocation
        self.router = router
        self.view = view
        self.networkManager = networkManager
    }
    
    func viewShown() {
        view?.setupViews()
        if let id = place?.id {
            getPlaceProperties(withID: id) { placeProp in
                self.placeProperties = placeProp
                self.view?.reloadData()
            }
        }
    }
    
    func distanceToUser(fromPlace place: MKMapItem) -> String? {
        if let userLocation = userLocation?.location, let placeLoc = place.placemark.location {
            return "\(Int(userLocation.distance(from: placeLoc))) м."
        } else {
            return nil
        }
    }
    
    private func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->()) {
        let url = APIProvider.shared.propertiesOfObjectURL(withId: id)
        networkManager?.fetchData(PlaceProperties.self, forURL: url) { result in
            switch result {
            case .success(let prop):
                completion(prop)
            case .failure(let error):
                completion(nil)
                print(error)
            }
        }
    }
    
}

extension PlaceDetailsPresenterImpl: PlaceDetailsPresenterDelegate {
    
    func makeRoute() {
        router?.makeRoute(place: placeProperties)
    }
    
}
