//
//  UILabel.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/20/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

extension UILabel {
  func withTextStyle(textStyle: UIFont.TextStyle) -> UILabel {
    self.font = UIFont.preferredFont(forTextStyle: textStyle)
    self.adjustsFontForContentSizeCategory = true
    return self
  }
}
