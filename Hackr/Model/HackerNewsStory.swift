//
//  HackerNewsStory.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsStory {

  let by: String?
  let descendants: Int?
  let id: String?
  let kids: [String]?
  let score: Int?
  let time: Date?
  let title: String?
  let url: String?

  init(json: [String: Any]) {
    by = json[HackerNewsItemFieldKeys.by] as? String ?? ""
    descendants = json[HackerNewsItemFieldKeys.descendants] as? Int ?? 0
    id = "\(json[HackerNewsItemFieldKeys.id] ?? "1")"
    kids = json[HackerNewsItemFieldKeys.kids] as? [String] ?? []
    score = json[HackerNewsItemFieldKeys.score] as? Int ?? 0
    if let timeInterval = json[HackerNewsItemFieldKeys.time] as? TimeInterval {
      time = Date(timeIntervalSince1970: timeInterval)
    } else {
      time = nil
    }
    title = json[HackerNewsItemFieldKeys.title] as? String ?? "Title"
    if let hackerNewsUrl = json[HackerNewsItemFieldKeys.url] as? String {
      url = hackerNewsUrl
    } else if let id = self.id {
      url = HackerNewsConstants.COMMENTS_URL + id
    } else {
      url = HackerNewsConstants.HOME_URL?.absoluteString
    }
  }
    
}
