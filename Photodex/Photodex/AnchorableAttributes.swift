//
//  AnchorableCollectionViewLayoutAttributes.swift
//  Photodex
//
//  Created by Michael Ward on 9/2/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class AnchorableAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let theCopy = super.copyWithZone(zone) as! AnchorableAttributes
        theCopy.anchorPoint = anchorPoint
        return theCopy
    }
    
}
