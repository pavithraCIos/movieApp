//
//  MovieCollectionCell.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var posterImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
