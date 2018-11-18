//
//  HackerNewsService.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsService {
    
    static private let BASE_URL = "https://hacker-news.firebaseio.com/v0/"
    static private let TOP_STORIES = "topstories"
    static private let NEW_STORIES = "newstories"
    static private let JSON = ".json"
    
    /// Sends a GET request to the Hacker News API for a given item type.
    ///
    /// - Parameters:
    ///     - type: The item type to get data for.
    static func getItemsForType(type: HackerNewsItemType) {
        var url: URL!
        switch type {
        case .topStories:
            url = URL(string: BASE_URL + TOP_STORIES + JSON)!
        case .newStories:
            url = URL(string: BASE_URL + NEW_STORIES + JSON)!
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.handleResponseForType(type: type, data: data, response: response, error: error)
        }
        task.resume()
    }
    
    private static func handleResponseForType(
        type: HackerNewsItemType, data: Data?, response: URLResponse?, error: Error?) {
        if let _ = error {
            print("An error occurred while getting items")
            return
        }
        guard let data = data else { return }
        HackerNewsParser.parseDataForType(type: type, data: data)
    }
}
