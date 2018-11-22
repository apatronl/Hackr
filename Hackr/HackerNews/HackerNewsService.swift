//
//  HackerNewsService.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsService {
    
    static let HOME_URL = URL(string: "https://news.ycombinator.com/news")
    static let COMMENTS_URL = "https://news.ycombinator.com/item?id="
    static private let BASE_URL = "https://hacker-news.firebaseio.com/v0/"
    static private let ITEM = "item/"
    static private let TOP_STORIES = "topstories"
    static private let NEW_STORIES = "newstories"
    static private let JSON = ".json"
    
    /// Sends a GET request to the Hacker News API for a given item type.
    ///
    /// - Parameters:
    ///     - type: The item type to get data for.
    ///     - completion: The function to execute when a story finished loading from the server. The
    ///         done field will only be true when all stories are done fetching.
    static func getStoriesForType(
        type: HackerNewsItemType,
        completion: @escaping (_ story: HackerNewsStory, _ done: Bool) -> ()) {
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
    
    /// Sends a GET request to the Hacker News API for a story given the story id.
    ///
    /// - Parameters:
    ///     - completion: The function to execute when a story finished loading from the server. The
    ///         done field will only be true when all stories are done fetching.
    private static func getStoriesFromIds(
        storyIds: [String], completion: @escaping (HackerNewsStory, Bool) -> ()) {
        if (storyIds.count == 0) { return }
        var storyIds = storyIds
        let id = storyIds.removeFirst()
        let url = URL(string: BASE_URL + ITEM + id + JSON)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let story =
                self.handleStoryResponse(data: data, response: response, error: error) {
                completion(story, storyIds.count == 0)
            }
            getStoriesFromIds(storyIds: storyIds, completion: completion)
        }
        task.resume()
    }

    /// Handles response for story ids. If data is successfully fetched, calls the parser method
    /// to return a list of story ids.
    ///
    /// - Parameters:
    ///     - data: The data returned by the server.
    ///     - response: An object that provides response metadata, such as HTTP headers and status
    ///         code. If you are making an HTTP or HTTPS request, the returned object is actually an
    ///         `HTTPURLResponse` object.
    ///     - error:  An error object that indicates why the request failed, or `nil` if the request
    ///         was successful.
    /// - Returns: A list of story ids.
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
