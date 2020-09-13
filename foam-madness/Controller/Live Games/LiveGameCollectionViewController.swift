//
//  LiveGameCollectionViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 9/12/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class LiveGameCollectionViewController: UICollectionViewController {
    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Other variables
    // TODO: Replace below with array of games downloaded from API
    var liveGames = [String]()
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure view respects the safe area
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }
        setFlowLayout()
    }
    
    // MARK: Collection View functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
        // TODO: Use actual games count
        //return liveGames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveGames", for: indexPath) as! LiveGameCollectionViewCell
        
        // TODO: Add actual games data to cells
        let indexInt = (indexPath as NSIndexPath).row
        if indexInt % 2 == 0 {
            cell.sportLabel.text = "NBA"
        } else {
            cell.sportLabel.text = "NCAA"
        }
        
        return cell
    }
    
    // MARK: Function to handle flow layout
    func setFlowLayout() {
        let space: CGFloat = 3.0
        let divisor: CGFloat = UIDevice.current.orientation.isPortrait ? 3.0 : 5.0
        let dimension = (view.safeAreaLayoutGuide.layoutFrame.width - (2 * space)) / divisor
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
