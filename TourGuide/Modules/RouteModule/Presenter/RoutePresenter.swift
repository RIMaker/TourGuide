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
    func getDirections()
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
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self?.view?.locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                self?.view?.showUserLocation()
            case .denied:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.view?.showAlert(
                        title: "Ваше местоположение недоступно",
                        message: "Перейдите в Настройки -> TourGuide -> Геопозиция")
                }
            default: break
            }
        }
    }
    
    func getDirections() {
        guard let location = view?.locationManager.location?.coordinate else {
            view?.showAlert(title: "Ошибка", message: "Текущее местопложение не обнаружено")
            return
        }
        
        guard let request = createDirectionRequest(from: location) else {
            view?.showAlert(title: "Ошибка", message: "Место назначения не найдено")
            return
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self?.view?.showAlert(title: "Ошибка", message: "Маршрут не доступен")
                return
            }
            let routes = response.routes.sorted { $0.expectedTravelTime < $1.expectedTravelTime }
            if let route = routes.first {
                self?.view?.addDirectionInMap(route: route)
            }
            
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard
            let lat = place?.point?.lat,
            let lon = place?.point?.lon
        else { return nil }
        
        let destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
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
        annotation.subtitle = place?.getAddress(type: .short)
        view?.showAnnotation(annotation: annotation)
    }
}
