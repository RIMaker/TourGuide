//
//  PlacesListVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 27.12.2022.
//

import Foundation
import MapKit

protocol PlacesListVCPresenter {
    var places: [MKMapItem] { get set }
    var naturalLanguageQuery: String { get set }
    var queries: [String] { get set }
    init(networkManager: NetworkManager, view: PlacesListController?)
    func viewShown()
    func distanceToUser(fromPlace place: MKMapItem) -> Int
    func add(placemark: CLPlacemark)
    func searchCompleted(placemark: CLPlacemark)
    func search(placemark: CLPlacemark, index: Int)
    func getLocation()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

class PlacesListVCPresenterImpl: PlacesListVCPresenter {
    
    let networkManager: NetworkManager
    
    weak var view: PlacesListController?
    
    var places = [MKMapItem]()
    var naturalLanguageQuery = "closest places to eat"
    var queries = ["restaurants"]
    private var userLocation: CLPlacemark?
    
    required init(networkManager: NetworkManager, view: PlacesListController? = nil) {
        self.networkManager = networkManager
        self.view = view
    }
    
    func viewShown() {
        view?.setupViews()
    }
    
    func distanceToUser(fromPlace place: MKMapItem) -> Int {
        if let userLocation = userLocation?.location, let placeLoc = place.placemark.location {
            return Int(userLocation.distance(from: placeLoc))
        } else {
            return 0
        }
    }
    
    func add(placemark: CLPlacemark) {
        userLocation = placemark
        search(placemark: placemark, index: self.queries.count - 1)
    }
    
    func searchCompleted(placemark: CLPlacemark) {
        stopUpdatingLocation()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.places = self.places.sorted(by: { (first, second) in
                if let firstName = first.name, let secondName = second.name {
                    return firstName < secondName
                } else {
                    return false
                }
            })
            
            var uniquePlaces = [MKMapItem]()
            for i in 0..<self.places.count - 1 {
                if self.places[i].name != self.places[i+1].name {
                    uniquePlaces.append(self.places[i])
                }
            }
            if let last = self.places.last, last.name != uniquePlaces.last?.name {
                uniquePlaces.append(last)
            }
            self.places = uniquePlaces
            DispatchQueue.main.async {
                self.view?.actIndStopAnimating()
                self.view?.reloadData()
            }
        }
    }
    
    func search(placemark: CLPlacemark, index: Int) {
        let request = MKLocalSearch.Request()
        guard let coordinate = placemark.location?.coordinate else { return }
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        request.naturalLanguageQuery = queries[index]
        MKLocalSearch(request: request).start { (response, error) in
            guard error == nil else { return }
            guard let response = response else { return }
            guard response.mapItems.count > 0 else { return }
            
            for item in response.mapItems {
                self.places.append(item)
            }
            
            if index != 0 {
                self.search(placemark: placemark, index: index - 1)
            } else {
                self.searchCompleted(placemark: placemark)
            }
        }
    }
    
    func getLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            view?.locationManager.requestLocation()
        }
    }
    
    func startUpdatingLocation() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.view?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.view?.locationManager.stopUpdatingLocation()
            }
        }
    }
    
}
