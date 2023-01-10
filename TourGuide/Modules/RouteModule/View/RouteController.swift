//
//  RouteController.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import UIKit
import MapKit

protocol RouteController: AnyObject {
    
}

class RouteControllerImpl: UIViewController, RouteController {
    
    var presenter: RoutePresenter?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }

}
