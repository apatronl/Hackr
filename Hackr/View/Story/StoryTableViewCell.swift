//
//  HNStoryTableViewCell.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/18/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

///
/// A `UITableViewCell` that shows a `HackerNewsStory` with a title, username, score, date, # of
/// comments, and comments button.
///
class StoryTableViewCell: UITableViewCell {
    
    var delegate: StoryTableViewCellDelegate?
    
    var story: HackerNewsStory? {
        didSet {
            titleLabel.text = story?.title
            let points = story?.score ?? 0
            authorAndPointsLabel.text =
                "👾 by \(story!.by!) | " +
                "\(getQuantityString(for: points, singular: "point", plural: "points")) 🔥"
            dateLabel.text = self.story?.time?.formatted()
            numberOfCommentsLabel.text = "\(story?.descendants ?? 0)"
            
            // Story details a11y
            authorAndPointsLabel.isAccessibilityElement = true
            authorAndPointsLabel.accessibilityLabel =
                "Story posted by \(story?.by ?? "unknown"), "
                + getQuantityString(for: points, singular: "point", plural: "points")
            numberOfCommentsLabel.isAccessibilityElement = false
            
            // Comments button a11y
            commentsImageView.isAccessibilityElement = true
            let numOfComments = story?.descendants ?? 0
            commentsImageView.accessibilityLabel =
                getQuantityString(for: numOfComments, singular: "comment", plural: "comments")
            commentsImageView.accessibilityHint = "Shows comments for this story"
            commentsImageView.accessibilityTraits = .button
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
    
    private let dateLabel: UILabel = {
        let label = UILabel().withTextStyle(textStyle: .caption1)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private let commentsImageView: UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "comments"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private let numberOfCommentsLabel: UILabel = {
        let label = UILabel().withTextStyle(textStyle: .caption1)
        label.textColor = UIColor.lightGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let commentsStack =
            UIStackView(arrangedSubviews: [commentsImageView, numberOfCommentsLabel])
        commentsStack.axis = .vertical
        commentsStack.distribution = .equalSpacing
        commentsStack.translatesAutoresizingMaskIntoConstraints = false
        commentsStack.spacing = 3
        commentsStack.alignment = .center
        
        self.addSubview(titleLabel)
        self.addSubview(authorAndPointsLabel)
        self.addSubview(dateLabel)
        self.addSubview(commentsStack)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: authorAndPointsLabel.topAnchor,
                          right: commentsStack.leftAnchor, paddingTop: 10, paddingLeft: 15,
                          paddingBottom: 5, paddingRight: 5, width: 0, height: 0,
                          enableInsets: false)

        authorAndPointsLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor,
                                    bottom: dateLabel.topAnchor, right: rightAnchor, paddingTop: 5,
                                    paddingLeft: 15, paddingBottom: 5, paddingRight: 50, width: 0,
                                    height: 0, enableInsets: false)
        
        dateLabel.anchor(top: authorAndPointsLabel.bottomAnchor, left: leftAnchor,
                         bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 15,
                         paddingBottom: 10, paddingRight: 50, width: 0, height: 0,
                         enableInsets: false)

        commentsStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        commentsStack.widthAnchor.constraint(equalToConstant: 70).isActive = true
        commentsStack.rightAnchor.constraint(equalTo: rightAnchor, constant: 5).isActive = true
        commentsStack.leftAnchor.constraint(
            equalTo: titleLabel.rightAnchor, constant: 5).isActive = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(StoryTableViewCell.commentsButtonTapped))
        commentsImageView.isUserInteractionEnabled = true
        commentsImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func commentsButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didPressCommentsButton(self)
    }

}

/// A method used by the delegate to respond to a tap event on the comments button of a
/// `StoryTableViewCell`

protocol StoryTableViewCellDelegate {
    func didPressCommentsButton(_ cell: StoryTableViewCell)
}
