//
//  RoutePresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import Foundation
import MapKit
import CoreLocation

protocol RoutePresenter {
    var place: PlaceProperties? { get }
    init(place: PlaceProperties?, view: RouteController?)
    func viewShown()
    func checkLocationAuthorization()
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: PlaceProperties?
    
    private weak var view: RouteController?
    
    required init(place: PlaceProperties?, view: RouteController?) {
        self.view = view
        self.place = place
    }
    
    func viewShown() {
        view?.setupViews()
        setupPlacemark()
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        DispatchQueue.main.async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self?.view?.locationManager.requestWhenInUseAuthorization()
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.view?.showUserLocation()
                default: break
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.view?.showAlert(
                        title: "Ваше местоположение недоступно",
                        message: "Перейдите в Настройки -> TourGuide -> Геопозиция")
                }
            }
        }
    }
    
    private func setupPlacemark() {
        guard
            let lat = place?.point?.lat,
            let lon = place?.point?.lon
        else { return }
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.coordinate = coordinate
        annotation.title = place?.name
        view?.showAnnotation(annotation: annotation)
    }
}
