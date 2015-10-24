//
//  PhotoCell.swift
//  Photodex
//
//  Created by Michael Ward on 9/2/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    override func applyLayoutAttributes(attributes: UICollectionViewLayoutAttributes) {
        
        defer {
            super.applyLayoutAttributes(attributes)
        }
        
        guard let anchorableAttributes = attributes as? AnchorableAttributes else {
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            return
        }
        
        layer.anchorPoint = anchorableAttributes.anchorPoint
        
    }
    
}
