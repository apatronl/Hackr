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
  private static var darkModeListeners = [DarkModeDelegate]()

  static func setDarkModeState(_ state: DarkModeState) {
    userDefaults.set(state.rawValue, forKey: Constants.key)
    darkModeListeners.forEach({ listener in
      listener.darkModeStateDidChange(state)
    })
  }

  static func getDarkModeState() -> DarkModeState {
    let rawState = userDefaults.string(forKey: Constants.key) ?? ""
    return DarkModeState(rawValue: rawState) ?? .off
  }

  static func addListener(_ listener: DarkModeDelegate) {
    darkModeListeners.append(listener)
  }
}

protocol DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState)
}
