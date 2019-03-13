//
//  MessageView.swift
//  Hackr
//
//  Created by Alejandrina Patron on 3/12/19.
//  Copyright © 2019 Alejandrina Patron. All rights reserved.
//

import UIKit

class MessageView: UIView {

  // MARK: - Constants

  enum Constants {
    static let height: CGFloat = 55.0
    static let labelFontSize: CGFloat = 12.0
    static let visibleAlpha: CGFloat = 0.95
    static let invisibleAlpha: CGFloat = 0.0
    static let animationDuration: TimeInterval = 0.8
    static let visibleDuration: TimeInterval = 2.5
  }

  // MARK: Private Properties

  private let messageLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .center
    label.textColor = .white
    label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .bold)
    return label
  }()

  private var message: String?

  init(frame: CGRect, message: String) {
    super.init(frame: frame)
    self.message = message
    buildView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func showAnimated() {
    UIView.animate(withDuration: Constants.animationDuration, animations: {
      var msgViewFrame = self.frame
      msgViewFrame.origin.y += AppDelegate.navigationBarHeight
      self.frame = msgViewFrame
      self.alpha = Constants.visibleAlpha
    }, completion: { completed in
      UIView.animate(
        withDuration: Constants.animationDuration, delay: Constants.visibleDuration,
        options: .beginFromCurrentState, animations: {
          var msgViewFrame = self.frame
          msgViewFrame.origin.y -= AppDelegate.navigationBarHeight
          self.frame = msgViewFrame
          self.alpha = Constants.invisibleAlpha
      }, completion: { _ in
          self.removeFromSuperview()
      })
    })
  }

  // MARK: - Private

  private func buildView() {
    messageLabel.text = message
    addSubview(messageLabel)
    alpha = Constants.invisibleAlpha
    backgroundColor = UIColor.hackerNewsOrange
    messageLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                        paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                        width: frame.width, height: frame.height, enableInsets: false)
  }
}
