//
//  MapVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import Foundation

protocol MapPresenter {
    var router: RouterMap? { get }
    init(view: MapViewController?, router: RouterMap?)
}

class MapPresenterImpl: MapPresenter {
    
    var router: RouterMap?
    
    private weak var view: MapViewController?
    
    required init(view: MapViewController?, router: RouterMap?) {
        self.view = view
        self.router = router
    }
    
}
