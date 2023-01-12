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
    init(place: PlaceProperties?, view: RouteController?)
    func viewShown(mapView: MKMapView)
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: PlaceProperties?
    var mapManager: MapManagerRouteModule?
    
    private weak var view: RouteController?
    
    required init(place: PlaceProperties?, view: RouteController?) {
        self.view = view
        self.place = place
    }
    
    func viewShown(mapView: MKMapView) {
        mapManager = MapManager(mapView: mapView)
        view?.setupViews()
        mapManager?.setupPlacemark(
            lat: place?.point?.lat,
            lon: place?.point?.lon,
            title: place?.name,
            subtitle: place?.getAddress(type: .short)
        )
    }
    
}
