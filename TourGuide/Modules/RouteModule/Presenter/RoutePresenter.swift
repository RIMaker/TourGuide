//
//  RoutePresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import Foundation

protocol RoutePresenter {
    init(place: Feature?, view: RouteController?)
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: Feature?
    
    private weak var view: RouteController?
    
    required init(place: Feature?, view: RouteController?) {
        self.view = view
        self.place = place
    }
    
}
