//
//  ProductTableViewCell.swift
//  DesafioB2W
//
//  Created by Rafael on 4/30/18.
//  Copyright © 2018 Rafael. All rights reserved.
//

import UIKit
import AlamofireImage

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productValue: UILabel!
    @IBOutlet weak var productInstallmentInfo: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var reviewRate: Array<UIImageView>!
    @IBOutlet weak var numReviews: UILabel!
    
    var imageURL: String = "" {
        didSet {
            // cancels image download request from previously used cell
            productImage.af_cancelImageRequest()
            // sets the product image based on the image URL fetched from the API
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let url = URL(string: imageURL)!
            productImage.af_setImage(withURL: url)
            activityIndicator.stopAnimating()
        }
    }

}
