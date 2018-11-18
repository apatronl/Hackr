//
//  TopViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit
import SafariServices

class TopStoriesViewController: UIViewController {

    var topStoriesTable: UITableView!
    var topStories = [HackerNewsStory]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Top Stories"

        topStoriesTable = UITableView(frame: self.view.frame)
        topStoriesTable.tableFooterView = UIView(frame: CGRect.zero)
        topStoriesTable.delegate = self
        topStoriesTable.dataSource = self
        self.view.addSubview(topStoriesTable)

        HackerNewsService.getStoriesForType(type: .topStories, completion: { story in
            self.topStories.append(story)
            self.topStoriesTable.reloadData()
        })
    }

}

extension TopStoriesViewController: UITableViewDelegate {
    
}

extension TopStoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Top Story") {
            cell.textLabel?.text = self.topStories[indexPath.row].title
            cell.detailTextLabel?.text = self.topStories[indexPath.row].by
            return cell
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Top Story")
        cell.textLabel?.text = self.topStories[indexPath.row].title
        cell.detailTextLabel?.text = self.topStories[indexPath.row].by
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: topStories[indexPath.row].url ?? "") {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
}
