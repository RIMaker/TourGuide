//
//  PlacesListVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 27.12.2022.
//

import Foundation
import MapKit

protocol PlacesListVCPresenter {
    var places: Places? { get }
    init(networkManager: NetworkManager, view: PlacesListController?)
    func viewShown()
    func startUpdatingLocation()
    func searchCompleted(placemark: CLPlacemark)
    func distanceToUser(fromPlace place: MKMapItem) -> Int
    func stopUpdatingLocation()
}

class PlacesListVCPresenterImpl: PlacesListVCPresenter {
    
    let networkManager: NetworkManager
    
    var places: Places?
    
    weak var view: PlacesListController?
    
    private var userLocation: CLPlacemark?
    
    required init(networkManager: NetworkManager, view: PlacesListController? = nil) {
        self.networkManager = networkManager
        self.view = view
    }
    
    func viewShown() {
        view?.setupViews()
        fetchData()
        requestLocation()
    }
    
    func fetchData() {
        view?.actIndStartAnimating()
        let url = APIProvider.shared.placesURL()
        networkManager.fetchData(Places.self, forURL: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    self.places = places
                    self.view?.actIndStopAnimating()
                    self.view?.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func getPlaceProperties(withID id: String, completion: @escaping (PlaceProperties?)->()) {
        let url = APIProvider.shared.propertiesOfObjectURL(withId: id)
        networkManager.fetchData(PlaceProperties.self, forURL: url) { result in
            switch result {
            case .success(let prop):
                completion(prop)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func distanceToUser(fromPlace place: MKMapItem) -> Int {
        if let userLocation = userLocation?.location, let placeLoc = place.placemark.location {
            return Int(userLocation.distance(from: placeLoc))
        } else {
            return 0
        }
    }
    
    func searchCompleted(placemark: CLPlacemark) {
        userLocation = placemark
        stopUpdatingLocation()
        DispatchQueue.main.async {
            self.view?.reloadData()
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
    
    func requestLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            view?.locationManager.requestWhenInUseAuthorization()
        }
        startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.view?.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func getAddressFromLatLon(lat: Double, lon: Double, completion: @escaping (String)->()) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        completion("")
                    }

                    if let placemarks = placemarks, placemarks.count > 0 {
                        let pm = placemarks[0]
                        
                        var addressString : String = ""
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ""
                        }

                        completion(addressString)
                    } else {
                        completion("")
                    }
            })

        }
    
}
