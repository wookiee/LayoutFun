//
//  FlipLayout
//  Photodex
//
//  Created by Michael Ward on 8/29/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FlipLayout: UICollectionViewLayout {
    
    // MARK: - State and Metrics
    private var cellAttributes: [NSIndexPath:UICollectionViewLayoutAttributes] = [:]
    private var cellSize: CGSize = CGSize.zero
    private var cellCenter: CGPoint = CGPoint.zero
    
    private var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }

    private var currentOffset: CGFloat {
        return (collectionView!.contentOffset.y + collectionView!.contentInset.top)
    }
    
    private var currentCellIndex: Int {
        return max(0, Int(currentOffset / cellSize.height))
    }
    
    private var layoutRect: CGRect! {
        var rect = CGRect(origin: CGPoint.zero, size: collectionView!.frame.size)
        rect = UIEdgeInsetsInsetRect(rect, collectionView!.contentInset)
        return rect
    }
    
    private var shouldLayoutFromScratch: Bool = true
    
    // MARK: - Basic Layout Overrides
    
    override func prepareLayout() {

        // Skip the layout preparation if the non-variable
        // attributes are still valid
        guard shouldLayoutFromScratch else {
            return
        }
        
        // Recalculate everything
        cellSize = CGSize(width: layoutRect.width, height: layoutRect.height / 2.0)
        cellCenter = CGPoint(x: layoutRect.width / 2.0, y: layoutRect.height / 2.0)
        
        cellAttributes = [:]
        for cellIndex in 0 ..< cellCount {
            let indexPath = NSIndexPath(forItem: cellIndex, inSection: 0)
            let attributes = AnchorableAttributes(forCellWithIndexPath: indexPath)
            attributes.size = cellSize
            attributes.center = cellCenter
            attributes.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            cellAttributes[indexPath] = attributes
        }
        shouldLayoutFromScratch = false

    }
    
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = layoutRect.width
        let contentHeight = (CGFloat(cellCount) * cellSize.height) + cellSize.height
        let contentSize = CGSizeMake(contentWidth, contentHeight)
        return contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        updateAttributesForItemAtIndexPath(indexPath)
        let attributes = cellAttributes[indexPath]
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for cellIndex in 0 ..< cellCount {
            let indexPath = NSIndexPath(forItem: cellIndex, inSection: 0)
            if let attributes = layoutAttributesForItemAtIndexPath(indexPath) {
                allAttributes.append(attributes)
            }
        }
        return allAttributes
    }
    
    // MARK: - Layout Invalidation Overrides
    
    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContextForBoundsChange(newBounds)
        
        if newBounds.size != collectionView!.bounds.size {
            shouldLayoutFromScratch = true
        }

        var indexPaths: [NSIndexPath] = []
        let index = currentCellIndex
        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
        if index > 0 {
            indexPaths.append(NSIndexPath(forItem: index - 1, inSection: 0))
        }
        
        if index < cellCount - 1 {
            indexPaths.append(NSIndexPath(forItem: index + 1, inSection: 0))
        }
        
        context.invalidateItemsAtIndexPaths(indexPaths)
        return context
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            shouldLayoutFromScratch = true
        }
        super.invalidateLayoutWithContext(context)
    }
    
    // MARK: - Transform Helpers
    
    private func updateAttributesForItemAtIndexPath(indexPath: NSIndexPath) {
        guard let attributes = cellAttributes[indexPath] else {
            return
        }
        
        switch indexPath.item {
        case currentCellIndex:
            let relativeOffset = currentOffset / cellSize.height
            // fractionComplete is the fractional progress from one cell to the next
            let fractionComplete = max(0, modf(relativeOffset).1)
            attributes.transform3D = transform3DForFlipCompletion(fractionComplete)
            attributes.zIndex = 1
            attributes.hidden = false
        case currentCellIndex + 1:
            attributes.transform3D = transform3DForFlipCompletion(0.0)
            attributes.zIndex = 0
            attributes.hidden = false
        case currentCellIndex - 1:
            attributes.transform3D = transform3DForFlipCompletion(1.0)
            attributes.zIndex = 0
            attributes.hidden = false
        default:
            attributes.transform3D = transform3DForFlipCompletion(0.0)
            attributes.zIndex = 0
            attributes.hidden = true
        }
        
    }

    private func transform3DForFlipCompletion(fractionComplete: CGFloat) -> CATransform3D {
        
        var transform = CATransform3DIdentity

        // Translate by the currentOffset so that the cell remains centered relative to
        // the screen even as the content area scrolls
        transform = CATransform3DTranslate(transform, 0.0, currentOffset, 0.0)
        
        // The anchorpoint is now in the top-center of the cell, so rotate vertically
        // about the X axis to flip the cell
        let rotation = CGFloat(M_PI) * fractionComplete
        transform = CATransform3DRotate(transform, rotation, 1, 0, 0)

        return transform
    }
}
