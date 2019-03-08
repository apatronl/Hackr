//
//  StoryDownloader.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/25/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

class StoryDownloadOperation: AsyncOperation {
  let url: URL
  let completion: (HackerNewsStory?, Error?) -> ()
  
  init(url: URL, completion: @escaping (HackerNewsStory?, Error?) -> ()) {
    self.url = url
    self.completion = completion
  }
  
  override func main() {
    if isCancelled {
      return
    }
  
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard !self.isCancelled else {
        self.state = .isFinished
        return
      }
      if let _ = error {
        self.completion(nil, error)
        self.state = .isFinished
        return
      }
      guard let data = data else {
        self.completion(nil, nil)
        self.state = .isFinished
        return
      }
      self.completion(HackerNewsParser.parseDataForStory(data: data), nil)
      self.state = .isFinished
    }
    task.resume()
  }
}
