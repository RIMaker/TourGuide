//
//  MapVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import Foundation

protocol MapVCPresenter {
    var router: Router? { get }
    init(view: MapViewController?, router: Router?)
}

class MapVCPresenterImpl: MapVCPresenter {
    
    var router: Router?
    
    weak var view: MapViewController?
    
    required init(view: MapViewController?, router: Router?) {
        self.view = view
        self.router = router
    }
    
}
