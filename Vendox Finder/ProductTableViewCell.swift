//
//  ProductTableViewCell.swift
//  Vendox Finder
//
//  Created by Tobias Feistmantl on 23/05/15.
//  Copyright (c) 2015 Vendox. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    var product: Product!
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCompanyNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDistanceToUserLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
