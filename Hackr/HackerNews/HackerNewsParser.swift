//
//  HackerNewsParser.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsParser {
    
  static func parseDataForStoryIds(data: Data) -> [String]? {
    if let text = String(data: data, encoding: String.Encoding.utf8) {
      let trimemdText = text.trimmingCharacters(in: CharacterSet.init(
        charactersIn: "[]")).replacingOccurrences(of: " ", with: "")
      let itemIds = trimemdText.components(separatedBy: ",")
      return itemIds
    }
    return nil
  }
  
  static func parseDataForStory(data: Data) -> HackerNewsStory? {
    do {
      if let json =
        try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        return HackerNewsStory(json: json)
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }
}
