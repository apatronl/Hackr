//
//  HackerNewsConstants.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/12/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsConstants {
  static let HOME_URL = URL(string: "https://news.ycombinator.com/news")
  static let COMMENTS_URL = "https://news.ycombinator.com/item?id="
  static let BASE_URL = "https://hacker-news.firebaseio.com/v0/"
  static let ITEM = "item/"
  static let TOP_STORIES = "topstories"
  static let BEST_STORIES = "beststories"
  static let NEW_STORIES = "newstories"
  static let JSON = ".json"

  static func urlForType(_ type: HackerNewsItemType) -> URL! {
    var typeUrl = ""
    switch type {
    case .topStories:
      typeUrl = TOP_STORIES
    case .bestStories:
      typeUrl = BEST_STORIES
    case .newStories:
      typeUrl = NEW_STORIES
    }
    return URL(string: BASE_URL + typeUrl + JSON)!
  }

  static func urlForId(_ id: String) -> URL! {
    return URL(string: BASE_URL + ITEM + id + JSON)!
  }
}
