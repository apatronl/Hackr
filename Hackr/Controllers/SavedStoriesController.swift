//
//  SavedStoriesController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 3/22/20.
//  Copyright © 2020 Alejandrina Patron. All rights reserved.
//

import Foundation

public struct SavedStoriesController {
  private static var listeners = [SavedStoriesControllerDelegate]()

  static func registerListener(_ listener: SavedStoriesControllerDelegate) {
    listeners.append(listener)
  }

  static func saveStory(_ story: HackerNewsStory) {
    var savedStories = self.getAllSavedStories()
    savedStories.append(story)
    self.saveStories(savedStories)
  }

  static func unsaveStory(at index: Int, _ story: HackerNewsStory) {
    var savedStories = self.getAllSavedStories()
    let storyToRemove = savedStories[index]
    assert(storyToRemove == story, "Attempted to remove incorrect saved story.")
    savedStories.remove(at: index)
    self.saveStories(savedStories)
  }

  static func getAllSavedStories() -> [HackerNewsStory] {
    guard let encodedData = UserDefaults.standard.array(
      forKey: UserDefaults.savedStoriesKey) as? [Data] else { return [] }
    return encodedData.map {
      try! JSONDecoder().decode(HackerNewsStory.self, from: $0)
    }
  }

  private static func saveStories(_ stories: [HackerNewsStory]) {
    let dataToSave = stories.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(dataToSave, forKey: UserDefaults.savedStoriesKey)
    listeners.forEach { $0.savedStoriesDidChange() }
  }
}

protocol SavedStoriesControllerDelegate {
  func savedStoriesDidChange()
}
