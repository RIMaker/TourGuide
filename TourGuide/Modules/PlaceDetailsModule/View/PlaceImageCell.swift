//
//  PlaceImageCell.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 07.01.2023.
//

import UIKit

class PlaceImageCell: UITableViewCell {
    
    static let cellId = "ImageCell"
    
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                placeImage.load(url: url)
            }
        }
    }
    
    private var placeImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(systemName: SystemSymbol.places.rawValue))
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(placeImage)
        placeImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        placeImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        placeImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        placeImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        placeImage.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        placeImage.heightAnchor.constraint(equalToConstant: 350).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder init isn't implemented")
    }

}
