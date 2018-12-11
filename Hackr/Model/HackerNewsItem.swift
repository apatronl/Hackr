//
//  HackerNewsItem.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

///
/// Hacker News API constants.
///
struct HackerNewsItemFieldKeys {
    static let id = "id"
    static let deleted = "deleted"
    static let type = "type"
    static let by = "by"
    static let time = "time"
    static let text = "text"
    static let dead = "dead"
    static let parent = "parent"
    static let poll = "poll"
    static let kids = "kids"
    static let url = "url"
    static let score = "score"
    static let title = "title"
    static let parts = "parts"
    static let descendants = "descendants"
}

///
/// Hacker News API request types.
///
enum HackerNewsItemType: String, CaseIterable {
    case topStories = "Top Stories"
    case newStories = "New Stories"
    case bestStories = "Best Stories"
}
