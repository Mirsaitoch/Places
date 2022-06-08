//
//  CustomTableViewCell.swift
//  Places
//
//  Created by Мирсаит Сабирзянов on 12/29/21.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet var cosmosView: CosmosView!{
        didSet{
            cosmosView.settings.updateOnTouch = false
        }
    }
    @IBOutlet weak var imageOfPlace: UIImageView!{
        didSet{
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
}
