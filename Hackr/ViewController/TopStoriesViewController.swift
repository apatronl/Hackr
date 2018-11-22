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
    
    private let cellIdentifier = "Top Story"

    private var topStoriesTable: UITableView!
    private var topStories = [HackerNewsStory]()
    private var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Top Stories"

        topStoriesTable = UITableView(frame: self.view.frame)
        topStoriesTable.tableFooterView = UIView(frame: CGRect.zero)
        topStoriesTable.delegate = self
        topStoriesTable.dataSource = self
        topStoriesTable.register(StoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshTopStories), for: .valueChanged)
        refresher.tintColor = UIColor.hackerNewsOrange
        topStoriesTable.refreshControl = refresher
        self.view.addSubview(topStoriesTable)
        
        if (traitCollection.forceTouchCapability == .available) {
            self.registerForPreviewing(with: self, sourceView: self.topStoriesTable)
        }

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

// MARK: UITableViewDataSource

extension TopStoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
        cell.delegate = self
        if (!refresher.isRefreshing) {
            cell.story = self.topStories[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.refresher.isRefreshing) { return }
        if let url = URL(string: topStories[indexPath.row].url ?? "") {
            guard let safariVC = self.safariViewForItem(
                at: url, defaultUrl: HackerNewsService.HOME_URL) else { return }
            self.present(safariVC, animated: true, completion: nil)
        }
        self.topStoriesTable.deselectRow(at: indexPath, animated: true)
    }
}

//extension TopStoriesViewController: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//
//    }
//}

// MARK: UIViewControllerPreviewingDelegate

extension TopStoriesViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.topStoriesTable.indexPathForRow(at: location) else { return nil }
        guard let cell = self.topStoriesTable.cellForRow(at: indexPath)
            as? StoryTableViewCell else { return nil }
        return self.safariViewForItem(
            at: URL(string: cell.story?.url ?? ""), defaultUrl: HackerNewsService.HOME_URL)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
    
}

extension TopStoriesViewController: StoryTableViewCellDelegate {

    func didPressCommentsButton(_ cell: StoryTableViewCell) {
        let url = URL(string: HackerNewsService.COMMENTS_URL + "\(cell.story?.id ?? "1")")
        guard let safariVC =
            self.safariViewForItem(at: url, defaultUrl: HackerNewsService.HOME_URL) else { return }
        self.present(safariVC, animated: true, completion: nil)
        
    }
    
}
