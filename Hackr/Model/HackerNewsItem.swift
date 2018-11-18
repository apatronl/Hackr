//
//  HackerNewsItem.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

enum HackerNewsItemFieldKeys: String, CodingKey {
    case id = "id"
    case deleted = "deleted"
    case type = "type"
    case by = "by"
    case time = "time"
    case text = "text"
    case dead = "dead"
    case parent = "parent"
    case poll = "poll"
    case kids = "kids"
    case url = "url"
    case score = "score"
    case title = "title"
    case parts = "parts"
    case descendants = "descendants"
}

enum HackerNewsItemType: String {
    case topStories = "Top Stories"
    case newStories = "New Stories"
}
