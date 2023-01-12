//
//  MapVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import Foundation
import MapKit

protocol MapPresenter {
    var router: RouterMap? { get }
    var mapManager: MapManagerMapModule? { get }
    init(view: MapViewController?, router: RouterMap?)
    func viewShown(mapView: MKMapView)
}

class MapPresenterImpl: MapPresenter {
    
    var router: RouterMap?
    
    var mapManager: MapManagerMapModule?
    
    private weak var view: MapViewController?
    
    required init(view: MapViewController?, router: RouterMap?) {
        self.view = view
        self.router = router
    }
    
    func viewShown(mapView: MKMapView) {
        mapManager = MapManager(mapView: mapView)
        view?.setupViews()
    }
    
}
