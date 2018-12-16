//
//  StoryCell.swift
//  Hackr Watch Extension
//
//  Created by Alejandrina Patron on 12/16/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import WatchKit

class StoryRowController: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var pointsLabel: WKInterfaceLabel!
    
    var title: String? {
        didSet {
            self.titleLabel.setText(title)
        }
    }
    
    var score: Int? {
        didSet {
            let s = score ?? 0
            let text = "\(getQuantityString(for: s, singular: "point", plural: "points")) 🔥"
            pointsLabel.setText(text)
        }
    }
}
