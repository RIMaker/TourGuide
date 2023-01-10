//
//  RoutePresenter.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 10.01.2023.
//

import Foundation

protocol RoutePresenter {
    var router: RouterRouteScreen? { get }
    init(place: Feature?, view: RouteController?, router: RouterRouteScreen?)
}

class RoutePresenterImpl: RoutePresenter {
    
    var place: Feature?
    
    var router: RouterRouteScreen?
    
    private weak var view: RouteController?
    
    required init(place: Feature?, view: RouteController?, router: RouterRouteScreen?) {
        self.view = view
        self.router = router
        self.place = place
    }
    
}
