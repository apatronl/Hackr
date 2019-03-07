//
//  UIViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/19/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
  func safariViewForItem(at url: URL?, defaultUrl: URL?) -> SFSafariViewController? {
    guard let url = url ?? defaultUrl else { return nil }
    let safariVC = SFSafariViewController(url: url)
    safariVC.preferredControlTintColor = UIColor.hackerNewsOrange
    safariVC.preferredBarTintColor =
      DarkModeController.getDarkModeState() == .on ? UIColor.darkModeGray : .white
    return safariVC
  }
}
