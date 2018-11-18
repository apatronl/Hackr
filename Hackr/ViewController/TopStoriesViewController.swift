//
//  TopViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

class TopStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topStoriesTable: UITableView!
    //var topStories: []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Top Stories"

        topStoriesTable = UITableView(frame: self.view.frame)
        topStoriesTable.tableFooterView = UIView(frame: self.view.frame)
        topStoriesTable.delegate = self
        topStoriesTable.dataSource = self
        self.view.addSubview(topStoriesTable)

        HackerNewsService.getItemsForType(type: .topStories)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}

