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
    self.by = json[HackerNewsItemFieldKeys.by] as? String ?? ""
    self.descendants = json[HackerNewsItemFieldKeys.descendants] as? Int ?? 0
    self.id = "\(json[HackerNewsItemFieldKeys.id] ?? "1")"
    self.kids = json[HackerNewsItemFieldKeys.kids] as? [String] ?? []
    self.score = json[HackerNewsItemFieldKeys.score] as? Int ?? 0
    if let timeInterval = json[HackerNewsItemFieldKeys.time] as? TimeInterval {
      self.time = Date(timeIntervalSince1970: timeInterval)
    } else {
      self.time = nil
    }
    self.title = json[HackerNewsItemFieldKeys.title] as? String ?? "Title"
    if let url = json[HackerNewsItemFieldKeys.url] as? String {
      self.url = url
    } else if let id = self.id {
      self.url = HackerNewsConstants.COMMENTS_URL + id
    } else {
      self.url = HackerNewsConstants.HOME_URL?.absoluteString
    }
  }
    
}
