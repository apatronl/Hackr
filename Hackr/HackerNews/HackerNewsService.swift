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
    static private var ids = [String]()
    static private var currentPage = 0
    static private let maxStoriesToLoad = 20
    static private var isFetching = false
    static private let storyFetchingQueue = OperationQueue()
    
    /// Sends a GET request to the Hacker News API for a given item type.
    ///
    /// - Parameters:
    ///     - type: The item type to get data for.
    ///     - completion: The function to execute when a story finished loading from the server. The
    ///         done field will only be true when all stories are done fetching.
    static func getStoriesForType(
        type: HackerNewsItemType,
        completion: @escaping (_ stories: [HackerNewsStory]?, _ error: Error?) -> ()) {
        resetFetch()
        var url: URL!
        switch type {
        case .topStories:
            url = URL(string: BASE_URL + TOP_STORIES + JSON)!
        case .newStories, .bestStories: // TODO: handle different story types once type menu is done
            url = URL(string: BASE_URL + NEW_STORIES + JSON)!
        }
        isFetching = true
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completion(nil, error)
                resetFetch()
                return
            }
            guard let ids =
                self.handleStoryIdsResponse(data: data, response: response, error: error) else {
                    // TODO: Better handle errors
                    print("Error")
                    resetFetch()
                    return
            }
            self.ids = ids
            self.getStoriesForIds(completion: completion)
        }
        task.resume()
    }
    

    /// Sends a GET request to the Hacker News API for a story given the fetched story ids.
    ///
    /// - Parameters:
    ///     - completion: The function to execute when all stories in the current page are finished
    ///         loading from the server.
    private static func getStoriesForIds(completion: @escaping([HackerNewsStory]?, Error?) -> ()) {
        let start = currentPage * maxStoriesToLoad
        let end = min((currentPage + 1) * maxStoriesToLoad - 1, ids.count - 1)
        if (start >= ids.count) {
            return
        }
        var stories = [HackerNewsStory]()
        var operations = [Operation]()
        for i in start...end {
            let id = ids[i]
            let operation = StoryDownloadOperation(
                url: URL(string: BASE_URL + ITEM + id + JSON)!, completion: { story, error in
                    if let _ = error {
                        completion(nil, error)
                        finishPageLoad(withSuccess: false)
                        return
                    }
                    guard let story = story else { return }
                    stories.append(story)
            })
            if i > start {
                operation.addDependency(operations[i % maxStoriesToLoad - 1])
            }
            operations.append(operation)
        }
        let finalOperation = BlockOperation(block: {
            completion(stories, nil)
            finishPageLoad(withSuccess: true)
        })
        if let op = operations.last {
            finalOperation.addDependency(op)
        }
        operations.append(finalOperation)
        storyFetchingQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    /// Loads more stories, if available, and if we're not currently in the process of fetching
    /// stories. This method is used to implement infinite scrolling in the main stories VC.
    ///
    /// - Parameters:
    ///     - type: The item type to get more stories for. NOTE: currently only handling top stories
    ///     - completion: The function to execute when all stories in the current page are finished
    ///         loading from the server.
    static func loadMoreStoriesForType(
        type: HackerNewsItemType,
        completion: @escaping (_ stories: [HackerNewsStory]?, _ error: Error?) -> ()) {
        if (self.isFetching) { return }
        self.getStoriesForIds(completion: completion)
    }
    
    private static func finishPageLoad(withSuccess: Bool) {
        if !withSuccess {
            storyFetchingQueue.cancelAllOperations()
        } else {
            currentPage += 1
        }
        isFetching = false
    }
    
    private static func resetFetch() {
        storyFetchingQueue.cancelAllOperations()
        isFetching = false
        currentPage = 0
        ids = []
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
}
