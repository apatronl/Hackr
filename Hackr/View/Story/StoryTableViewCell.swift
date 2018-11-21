//
//  HNStoryTableViewCell.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/18/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
    
    var story: HackerNewsStory? {
        didSet {
            titleLabel.text = story?.title
            authorAndPointsLabel.text = "👾 by \(story!.by!) | \(story!.score!) points 🔥"
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel().withTextStyle(textStyle: .body)
        label.numberOfLines = 0
        label.textColor = UIColor.black
        return label
    }()
    
    private let authorAndPointsLabel: UILabel = {
        let label = UILabel().withTextStyle(textStyle: .caption1)
        label.textColor = UIColor.lightGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        self.addSubview(titleLabel)
        self.addSubview(authorAndPointsLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: authorAndPointsLabel.topAnchor,
                          right: rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 5,
                          paddingRight: 35, width: 0, height: 0, enableInsets: false)
        authorAndPointsLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor,
                                    bottom: bottomAnchor, right: rightAnchor, paddingTop: 5,
                                    paddingLeft: 15, paddingBottom: 10, paddingRight: 35, width: 0,
                                    height: 0, enableInsets: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
