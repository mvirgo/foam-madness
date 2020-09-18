//
//  AboutViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 9/17/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        // Load "About" page text
        if let url = Bundle.main.url(forResource: "ABOUT", withExtension: ".rtf") {
            aboutTextView.attributedText = try! NSMutableAttributedString(url: url, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            
            // Set colors
            if #available(iOS 13.0, *) {
                aboutTextView.backgroundColor = .systemBackground
                aboutTextView.textColor = .label
            } else {
                // Fallback on earlier versions
                aboutTextView.backgroundColor = .white
                aboutTextView.textColor = .black
            }
        }
    }
}
