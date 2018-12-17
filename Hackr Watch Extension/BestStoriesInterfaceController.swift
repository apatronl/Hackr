//
//  BestStoriesInterfaceController.swift
//  Hackr Watch Extension
//
//  Created by Alejandrina Patron on 12/16/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import WatchKit
import Foundation


class BestStoriesInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var storiesTableView: WKInterfaceTable!
    
    var hnService: HackerNewsService!
    var stories: [HackerNewsStory]!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.hnService = HackerNewsService(type: .bestStories, maxStoriesToLoad: 5)
        self.loadStories()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func loadStories() {
        self.hnService.getStories(completion: { (stories, error) in
            guard let stories = stories else { return }
            self.stories = stories
            self.updateTable()
        })
    }
    
    private func updateTable() {
        storiesTableView.setNumberOfRows(self.stories.count, withRowType: "StoryRowController")
        for (i, story) in self.stories.enumerated() {
            let row = storiesTableView.rowController(at: i) as! StoryRowController
            row.title = story.title
            row.score = story.score
        }
    }

}
