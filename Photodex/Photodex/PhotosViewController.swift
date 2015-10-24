//
//  PhotosViewController.swift
//  Photodex
//
//  Created by Michael Ward on 8/25/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

let PhotoCellIdentifier = "PhotoCell"

class PhotosViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: "pinched:")
        collectionView?.addGestureRecognizer(pinchGR)
        
        collectionView?.reloadData()
    }
    
    // MARK: - Handling Pinches
    
    private var initialScale: CGFloat = 1.0
    private var isTransitioning: Bool = false
    private var transitionLayout: UICollectionViewTransitionLayout?
    
    @objc private func pinched(gr: UIPinchGestureRecognizer) {
        switch gr.state {
        case .Began:
            print("gesture began with scale \(gr.scale) velocity \(gr.velocity)")
            let currentLayout = collectionView!.collectionViewLayout
            let nextLayout = (currentLayout is FlipLayout) ? SpaceFillingFlowLayout() : FlipLayout()
            transitionLayout = collectionView!.startInteractiveTransitionToCollectionViewLayout(nextLayout, completion: { (animationCompleted, transitionCompleted) -> Void in
                print("interactive transition completion executing")
            })
        case .Changed:
            print("gesture changed to \(gr.scale) at \(gr.velocity))")
            let progress: CGFloat
            let startingScale: CGFloat = 1.0
            let currentScale = gr.scale
            let targetScale: CGFloat
            if transitionLayout?.nextLayout is FlipLayout {
                targetScale = 0.25
                progress = (startingScale - currentScale) / (startingScale - targetScale)
            } else {
                targetScale = 4.0
                progress = (currentScale - startingScale) / (targetScale - startingScale)
            }
            transitionLayout!.transitionProgress = progress
        case .Ended:
            print("gesture ended")
            if transitionLayout!.transitionProgress > 0.7 {
                collectionView!.finishInteractiveTransition()
            } else {
                collectionView!.cancelInteractiveTransition()
            }
        default:
            print("gesture state \(gr.state)")
        }
    }

}

// MARK: - Collection View Data Source
extension PhotosViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
            
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
            
    }
    
}
