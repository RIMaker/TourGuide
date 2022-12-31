//
//  LoadingReusableView.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 31.12.2022.
//

import UIKit

class LoadingReusableView: UICollectionReusableView {
    
//    private let activityIndicator: UIActivityIndicatorView = {
//        let actvInd = UIActivityIndicatorView()
//        actvInd.translatesAutoresizingMaskIntoConstraints = false
//        actvInd.startAnimating()
//        return actvInd
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder) is not implemented")
    }
    
}
