//
//  HackerNewsService.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

class HackerNewsService {
    
    private var url: URL!

    private var ids = [String]()
    private var currentPage = 0
    private var maxStoriesToLoad = 5
    private var isFetching = false
    private let storyFetchingQueue = OperationQueue()
    typealias Completion = ([HackerNewsStory]?, Error?) -> Void
    
    init(type: HackerNewsItemType, maxStoriesToLoad: Int) {
        self.url = HackerNewsConstants.urlForType(type)
        self.maxStoriesToLoad = maxStoriesToLoad
    }
    
    /// Sends a GET request to the Hacker News API for a given item type.
    ///
    /// - Parameters:
    ///     - type: The item type to get data for.
    ///     - completion: The function to execute when a story finished loading from the server. The
    ///         done field will only be true when all stories are done fetching.
    func getStories(completion: @escaping Completion) {
        resetFetch()
        self.isFetching = true
        let task = URLSession.shared.dataTask(with: self.url) { (data, response, error) in
            if let _ = error {
                completion(nil, error)
                self.resetFetch()
                return
            }
            guard let ids =
                self.handleStoryIdsResponse(data: data, response: response, error: error) else {
                    // TODO: Better handle errors
                    print("Error")
                    self.resetFetch()
                    return
            }
            self.ids = ids
            self.getStoriesForIds(completion: completion)
        }
        task.resume()
    }
    

    /// Sends a GET request to the Hacker News API to get stories given the fetched story ids.
    ///
    /// - Parameters:
    ///     - completion: The function to execute when all stories in the current page are finished
    ///         loading from the server.
    private func getStoriesForIds(completion: @escaping Completion) {
        let start = currentPage * self.maxStoriesToLoad
        let end = min((currentPage + 1) * self.maxStoriesToLoad - 1, ids.count - 1)
        if (start >= ids.count) {
            return
        }
        var stories = [HackerNewsStory]()
        var operations = [Operation]()
        for i in start...end {
            let id = ids[i]
            let operation = StoryDownloadOperation(
                url: HackerNewsConstants.urlForId(id), completion: { story, error in
                    if let _ = error {
                        completion(nil, error)
                        self.finishPageLoad(withSuccess: false)
                        return
                    }
                    guard let story = story else { return }
                    stories.append(story)
            })
            if i > start {
                operation.addDependency(operations[i % self.maxStoriesToLoad - 1])
            }
            operations.append(operation)
        }
        let finalOperation = BlockOperation(block: {
            completion(stories, nil)
            self.finishPageLoad(withSuccess: true)
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
    func loadMoreStories(completion: @escaping Completion) {
        if (self.isFetching) { return }
        self.getStoriesForIds(completion: completion)
    }
    
    /// Finishes a page load
    ///
    /// - Parameters:
    ///     - withSuccess: Whether the page load succeeded, that is, whether we were able to fetch
    ///         the next `maxStoriesToLoad` stories.
    private func finishPageLoad(withSuccess: Bool) {
        if !withSuccess {
            storyFetchingQueue.cancelAllOperations()
        } else {
            currentPage += 1
        }
        isFetching = false
    }
    
    /// Resets a fetch by canceling all operations and re-initializing the current page to 0,
    /// removing all currently loaded story ids.
    private func resetFetch() {
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
    ///     - error: An error object that indicates why the request failed, or `nil` if the request
    ///         was successful.
    /// - Returns: A list of story ids.
    private func handleStoryIdsResponse(
        data: Data?, response: URLResponse?, error: Error?) -> [String]? {
        if let _ = error {
            print("An error occurred while getting items")
            return nil
        }
        guard let data = data else { return nil }
        return HackerNewsParser.parseDataForStoryIds(data: data)
    }
}
