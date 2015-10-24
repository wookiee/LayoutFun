//
//  SpaceFillingFlowLayout.swift
//  Photodex
//
//  Created by Michael Ward on 8/25/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SpaceFillingFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - External Configuration
    
    @IBInspectable var minCellSize: CGSize = CGSizeMake(96, 96) {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var cellSpacing: CGFloat = 8 {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: - Internal Metrics
    
    private var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }
    private var contentSize: CGSize = CGSize.zero
    private var columns: Int = 0
    private var rows: Int = 0
    private var cellSize: CGSize = CGSize.zero
    private var cellCenterPoints: [CGPoint] = []
    
    // MARK: - Layout Overrides
    
    override func prepareLayout() {
        let collectionViewWidth = collectionView!.frame.size.width
        
        // Calculate the number of rows and columns (yay algebra!)
        columns = Int( (collectionViewWidth - cellSpacing) / (minCellSize.width + cellSpacing) )
        rows = Int( ceil(Double(cellCount) / Double(columns)) )
        
        // Take the remaining gap and divide it among the existing columns
        let innerWidth = (CGFloat(columns) * (minCellSize.width + cellSpacing)) + cellSpacing
        let extraWidth = collectionViewWidth - innerWidth
        let cellGrowth = extraWidth / CGFloat(columns)
        cellSize.width = floor(minCellSize.width + cellGrowth)
        cellSize.height = cellSize.width
        
        // For each cell, calculate its center point
        for itemIndex in 0 ..< cellCount {
            // Locate the cell's position in the grid
            let coordBreakdown = modf(CGFloat(itemIndex) / CGFloat(columns))
            let row = Int(coordBreakdown.0) + 1
            let col = Int(round(coordBreakdown.1 * CGFloat(columns))) + 1
            
            // Calculate the actual centerpoint of the cell, given its position
            var cellBottomRight = CGPoint.zero
            cellBottomRight.x = CGFloat(col) * (cellSpacing + cellSize.width)
            cellBottomRight.y = CGFloat(row) * (cellSpacing + cellSize.height)
            
            var cellCenter = CGPoint.zero
            cellCenter.x = cellBottomRight.x - (cellSize.width / 2.0)
            cellCenter.y = cellBottomRight.y - (cellSize.height / 2.0)
            
            cellCenterPoints.append(cellCenter)
        }
        print("columns: \(columns), rows: \(rows)")
        print("cell size: \(cellSize)")
    }
    
    override func collectionViewContentSize() -> CGSize {
        // Calculate and cache the total content size
        let contentWidth = (cellSize.width + cellSpacing) * CGFloat(columns) + cellSpacing
        let contentHeight = (cellSize.height + cellSpacing) * CGFloat(rows) + cellSpacing
        let contentSize = CGSizeMake(contentWidth, contentHeight)
        print("content size: \(contentSize), collection size: \(collectionView!.frame.size)")
        return contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) else {
            return nil
        }
        
        attributes.size = cellSize
        attributes.center = cellCenterPoints[indexPath.row]
        
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for itemIndex in 0 ..< cellCount {
            if CGRectContainsPoint(rect, cellCenterPoints[itemIndex]) {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                let attributes = layoutAttributesForItemAtIndexPath(indexPath)!
                allAttributes.append(attributes)
            }
        }
        
        return allAttributes
    }
    
}
