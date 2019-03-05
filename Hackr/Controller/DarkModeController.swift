//
//  DarkModeController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 3/4/19.
//  Copyright © 2019 Alejandrina Patron. All rights reserved.
//

import Foundation

public enum DarkModeState: String {
  case on
  case off
}

struct DarkModeController {

  // MARK: - Constants

  enum Constants {
    static let key = "HackrSettings.DarkModeState"
  }

  private static let userDefaults = UserDefaults.standard

  static func setDarkModeState(_ state: DarkModeState) {
    userDefaults.set(state.rawValue, forKey: Constants.key)
  }

  static func getDarkModeState() -> DarkModeState {
    if let rawState = userDefaults.string(forKey: Constants.key),
       let darkModeState = DarkModeState(rawValue: rawState) {
      return darkModeState
    }
    return .off
  }
}
