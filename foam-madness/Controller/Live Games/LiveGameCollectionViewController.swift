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
    var liveGames = [Event]()
    var leagueForGames = [Int: String]()
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure view respects the safe area
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }
        loadGames()
        setFlowLayout()
    }
    
    // MARK: Collection View functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveGames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveGames", for: indexPath) as! LiveGameCollectionViewCell
        
        // Add game data to cell
        let indexInt = (indexPath as NSIndexPath).row
        cell.sportLabel.text = leagueForGames[indexInt]
        // Note: all arrays except `competitors` have only 1 item
        let game = liveGames[indexInt]
        let teams = game.competitions[0].competitors
        cell.team1Label.text = teams[0].team.abbreviation
        cell.score1Label.text = teams[0].score
        cell.team2Label.text = teams[1].team.abbreviation
        cell.score2Label.text = teams[1].score
        cell.timeLabel.text = game.status.type.shortDetail
        if !game.status.type.completed {
            cell.timeLabel.text = game.status.displayClock + " " + cell.timeLabel.text!
        }
        
        return cell
    }
    
    // MARK: Function to handle flow layout
    func setFlowLayout() {
        let space: CGFloat = 3.0
        let divisor: CGFloat = UIDevice.current.orientation.isPortrait ? 3.0 : 4.0
        let dimension = (view.safeAreaLayoutGuide.layoutFrame.width - (2 * space)) / divisor
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: Background messaging while loading/empty
    func handleBackgroundMessage(loading: Bool) {
        if liveGames.count > 0 {
            self.collectionView.backgroundView = nil
        } else {
            // Add a label to the background
            // Based on https://stackoverflow.com/questions/43772984/how-to-show-a-message-when-collection-view-is-empty
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.view.safeAreaLayoutGuide.layoutFrame.height))
            if #available(iOS 13.0, *) {
                messageLabel.textColor = .label
            } else {
                // Fallback on earlier versions
                messageLabel.textColor = .black
            }
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont.systemFont(ofSize: 30)
            messageLabel.sizeToFit()

            if loading {
                // Show load label
                messageLabel.text = "Loading games..."
            } else {
                // Show empty label
                messageLabel.text = "No games found."
            }
            
            self.collectionView.backgroundView = messageLabel
            self.collectionView.backgroundView?.isHidden = false
        }
    }
    
    // MARK: API processing
    func loadGames() {
        handleBackgroundMessage(loading: true)
        APIClient.getScores(url: APIClient.Endpoints.getNCAAScores.url, completion: handleLiveGameScores(response:error:))
        APIClient.getScores(url: APIClient.Endpoints.getNBAScores.url, completion: handleLiveGameScores(response:error:))
    }
    
    func handleLiveGameScores(response: LiveGamesResponse?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else if let response = response {
            // Add events to liveGames array
            for game in response.events {
                // Note that there will only be one league in NCAA or NBA API
                leagueForGames[liveGames.count] = response.leagues[0].abbreviation
                liveGames.append(game)
            }
            self.collectionView.reloadData()
        }
        handleBackgroundMessage(loading: false)
    }
}
