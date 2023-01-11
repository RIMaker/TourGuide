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
    var mapManager: MapManager? { get }
    init(place: PlaceProperties?, mapManager: MapManager, view: RouteController?)
    func viewShown(mapView: MKMapView)
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: PlaceProperties?
    var mapManager: MapManager?
    
    private weak var view: RouteController?
    
    required init(place: PlaceProperties?, mapManager: MapManager, view: RouteController?) {
        self.view = view
        self.place = place
        self.mapManager = mapManager
    }
    
    func viewShown(mapView: MKMapView) {
        view?.setupViews()
        mapManager?.setupPlacemark(place: place, mapView: mapView)
    }
    
}
