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
  
  enum Constants {
    static let authorEmoji = "👾"
    static let comment = "comment"
    static let comments = "comments"
    static let commentsA11yHint = "Shows comments for this story"
    static let point = "point"
    static let points = "points"
    static let pointsEmoji = "🔥"
    static let unknownAuthor = "unknown"
  }

  var delegate: StoryTableViewCellDelegate?

  var story: HackerNewsStory? {
    didSet {
      titleLabel.text = story?.title
      authorAndPointsLabel.text = getAuthorAndPointsLabelText()
      dateLabel.text = story?.time?.formatted()
      numberOfCommentsLabel.text = "\(story?.descendants ?? 0)"

      // Story details a11y
      authorAndPointsLabel.isAccessibilityElement = true
      authorAndPointsLabel.accessibilityLabel = getAuthorAndPointsA11yLabelText()
      numberOfCommentsLabel.isAccessibilityElement = false

      // Comments button a11y
      commentsImageView.isAccessibilityElement = true
      let numOfComments = story?.descendants ?? 0
      commentsImageView.accessibilityLabel =
          getQuantityString(for: numOfComments,
                            singular: Constants.comment,
                            plural: Constants.comments)
      commentsImageView.accessibilityHint = Constants.commentsA11yHint
      commentsImageView.accessibilityTraits = .button
    }
  }

  var darkModeState: DarkModeState = .off {
    didSet {
      titleLabel.textColor = darkModeState == .on ? .white : .black
      backgroundColor = darkModeState == .on ? UIColor.darkModeGray : .white
      let bgColorView = UIView()
      bgColorView.backgroundColor = darkModeState == .on ? .darkGray : .lightGray
      selectedBackgroundView = bgColorView
      selectionStyle = .default
    }
  }

  private let titleLabel: UILabel = {
    let label = UILabel().withTextStyle(textStyle: .body)
    label.numberOfLines = 0
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

    addSubview(titleLabel)
    addSubview(authorAndPointsLabel)
    addSubview(dateLabel)
    addSubview(commentsStack)

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

    commentsStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
    delegate?.didPressCommentsButton(self)
  }

  // MARK: - Private

  private func getAuthorAndPointsLabelText() -> String {
    let points = story?.score ?? 0
    return "\(Constants.authorEmoji) by \(story?.by ?? "\(Constants.unknownAuthor)") | "
      + "\(getQuantityString(for: points, singular: Constants.point, plural: Constants.points)) "
      + "\(Constants.pointsEmoji)"
  }

  private func getAuthorAndPointsA11yLabelText() -> String {
    let points = story?.score ?? 0
    return "Story posted by \(story?.by ?? "\(Constants.unknownAuthor)"), "
      + getQuantityString(for: points, singular: Constants.point, plural: Constants.points)
  }
}

/// A method used by the delegate to respond to a tap event on the comments button of a
/// `StoryTableViewCell`

protocol StoryTableViewCellDelegate {
    func didPressCommentsButton(_ cell: StoryTableViewCell)
}
