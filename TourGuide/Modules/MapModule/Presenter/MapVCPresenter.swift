//
//  MapVCPresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.10.2022.
//

import Foundation

protocol MapVCPresenter {
    init(view: MapViewController?)
}

class MapVCPresenterImpl: MapVCPresenter {
    
    weak var view: MapViewController?
    
    required init(view: MapViewController? = nil) {
        self.view = view
    }
    
}
