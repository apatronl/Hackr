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
    static private let ITEM = "item/"
    static private let TOP_STORIES = "topstories"
    static private let NEW_STORIES = "newstories"
    static private let JSON = ".json"
    
    /// Sends a GET request to the Hacker News API for a given item type.
    ///
    /// - Parameters:
    ///     - type: The item type to get data for.
    static func getStoriesForType(
        type: HackerNewsItemType, completion: @escaping (HackerNewsStory) -> ()) {
        var url: URL!
        switch type {
        case .topStories:
            url = URL(string: BASE_URL + TOP_STORIES + JSON)!
        case .newStories:
            url = URL(string: BASE_URL + NEW_STORIES + JSON)!
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let ids =
                self.handleStoryIdsResponse(data: data, response: response, error: error) else {
                    // TODO: Better handle error
                    print("Error")
                    return
            }
            self.getStoriesFromIds(storyIds: ids, completion: completion)
        }
        task.resume()
    }
    
    private static func getStoriesFromIds(
        storyIds: [String], completion: @escaping (HackerNewsStory) -> ()) {
        for id in storyIds {
            let url = URL(string: BASE_URL + ITEM + id + JSON)!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if let story =
                        self.handleStoryResponse(data: data, response: response, error: error) {
                        completion(story)
                    }
                }
            }
            task.resume()
        }
    }
    
    private static func handleStoryIdsResponse(
        data: Data?, response: URLResponse?, error: Error?) -> [String]? {
        if let _ = error {
            print("An error occurred while getting items")
            return nil
        }
        guard let data = data else { return nil }
        return HackerNewsParser.parseDataForStoryIds(data: data)
    }
    
    private static func handleStoryResponse(
        data: Data?, response: URLResponse?, error: Error?) -> HackerNewsStory? {
        if let _ = error {
            print("An error occurred while getting items")
            return nil
        }
        guard let data = data else { return nil }
        return HackerNewsParser.parseDataForStory(data: data)
    }
}