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
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Top Stories"

        topStoriesTable = UITableView(frame: self.view.frame)
        topStoriesTable.tableFooterView = UIView(frame: CGRect.zero)
        topStoriesTable.delegate = self
        topStoriesTable.dataSource = self
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshTopStories), for: .valueChanged)
        refresher.tintColor = UIColor.hackerNewsOrange
        topStoriesTable.refreshControl = refresher
        self.view.addSubview(topStoriesTable)

        HackerNewsService.getStoriesForType(type: .topStories, completion: { story, done in
            DispatchQueue.main.async {
                self.topStories.append(story)
                if (done) {
                    print("Done")
                }
                self.topStoriesTable.reloadData()
            }
        })
    }

    @objc private func refreshTopStories() {
        URLSession.shared.getAllTasks(completionHandler: { tasks in
            tasks.forEach({ task in
                task.cancel()
            })
            DispatchQueue.main.async {
                self.topStories = []
                self.topStoriesTable.reloadData()
            }
            HackerNewsService.getStoriesForType(type: .topStories, completion: { story, done in
                DispatchQueue.main.async {
                    self.topStories.append(story)
                    if (done) {
                        print("Done")
                        self.refresher.endRefreshing()
                    }
                    self.topStoriesTable.reloadData()
                }
            })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Top Story")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Top Story")
        if (!refresher.isRefreshing) {
            cell.textLabel?.text = "\(indexPath.row + 1). " + self.topStories[indexPath.row].title!
            cell.detailTextLabel?.text = self.topStories[indexPath.row].by
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.refresher.isRefreshing) { return }
        self.topStoriesTable.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: topStories[indexPath.row].url ?? "") {
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredControlTintColor = UIColor.hackerNewsOrange
            self.present(safariVC, animated: true, completion: nil)
        }
    }
}

//extension TopStoriesViewController: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//
//    }
//}
