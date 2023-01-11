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
    var mapManager: MapManagerRouteModule? { get }
    init(place: PlaceProperties?, mapManager: MapManagerRouteModule, view: RouteController?)
    func viewShown(mapView: MKMapView)
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: PlaceProperties?
    var mapManager: MapManagerRouteModule?
    
    private weak var view: RouteController?
    
    required init(place: PlaceProperties?, mapManager: MapManagerRouteModule, view: RouteController?) {
        self.view = view
        self.place = place
        self.mapManager = mapManager
    }
    
    func viewShown(mapView: MKMapView) {
        view?.setupViews()
        mapManager?.setupPlacemark(place: place, mapView: mapView)
    }
    
}
