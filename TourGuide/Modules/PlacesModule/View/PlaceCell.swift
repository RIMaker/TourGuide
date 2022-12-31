//
//  PlaceCell.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 18.12.2022.
//

import UIKit

class PlaceCell: UICollectionViewCell {
    
    var place: PlaceProperties? {
        didSet {
            if let place = place, let url = URL(string: place.image ?? "") {
                DispatchQueue.main.async {
                    self.imageView.load(url: url)
                    self.nameLabel.text = place.name
                }
            }
        }
    }
    
    private var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.image = UIImage(systemName: SystemSymbol.places.rawValue)
        img.layer.cornerRadius = 12
        return img
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.text = "Hello, my name is James Arthur! What is your name? Hello, my name is James Arthur! What is your name?"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentView.frame.height * 0.3).isActive = true
        
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo:  imageView.bottomAnchor, constant: 10).isActive = true
        
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 4.0, height: 2.0)
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.masksToBounds = false
        
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder) is not implemented")
    }
    
}
