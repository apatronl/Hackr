//
//  StoriesViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/10/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit
import SafariServices

class StoriesViewController: UIViewController {
    
    private var storiesTable: UITableView!
    private var topStories = [HackerNewsStory]()
    private var refresher: UIRefreshControl!
    private var spinner: UIActivityIndicatorView!
    
    var storyType: HackerNewsItemType

    public init(for storyType: HackerNewsItemType) {
        self.storyType = storyType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storiesTable = UITableView()
        storiesTable.tableFooterView = UIView(frame: CGRect.zero)
        storiesTable.dataSource = self
        storiesTable.delegate = self
        storiesTable.register(StoryTableViewCell.self,
                                 forCellReuseIdentifier: StoryTableViewCell.identifier)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshTopStories), for: .valueChanged)
        refresher.tintColor = UIColor.hackerNewsOrange
        storiesTable.refreshControl = refresher
        self.view.addSubview(storiesTable)
        storiesTable.anchor(top: self.view.topAnchor, left: self.view.leftAnchor,
                               bottom: self.view.bottomAnchor, right: self.view.rightAnchor,
                               paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                               width: 0, height: 0, enableInsets: false)
        
        if (traitCollection.forceTouchCapability == .available) {
            self.registerForPreviewing(with: self, sourceView: self.storiesTable)
        }
        
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = UIColor.hackerNewsOrange
        spinner.autoresizingMask =
            [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        HackerNewsService.getStoriesForType(type: self.storyType, completion: { stories, error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                if let _ = error {
                    return
                }
                if let stories = stories {
                    self.topStories += stories
                    self.storiesTable.reloadData()
                }
            }
        })
    }
    
    @objc private func refreshTopStories() {
        self.topStories = []
        self.storiesTable.reloadData()
        HackerNewsService.getStoriesForType(type: .topStories, completion: { stories, error in
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
                if let _ = error {
                    return
                }
                guard let stories = stories else { return }
                self.topStories += stories
                self.storiesTable.reloadData()
            }
        })
    }
}

extension StoriesViewController: UITableViewDelegate {}

// MARK: UITableViewDataSource

extension StoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StoryTableViewCell.identifier) as! StoryTableViewCell
        cell.delegate = self
        if (!refresher.isRefreshing) {
            cell.story = self.topStories[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.refresher.isRefreshing { return }
        if let url = URL(string: topStories[indexPath.row].url ?? "") {
            guard let safariVC = self.safariViewForItem(
                at: url, defaultUrl: HackerNewsService.HOME_URL) else { return }
            self.present(safariVC, animated: true, completion: nil)
        }
        self.storiesTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == self.topStories.count - 1 {
            HackerNewsService.loadMoreStoriesForType(
                type: .topStories, completion: { stories, error in
                    DispatchQueue.main.async {
                        if let _ = error { return }
                        guard let stories = stories else { return }
                        if stories.isEmpty { return }
                        self.topStories += stories
                        self.storiesTable.reloadData()
                    }
            })
        }
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension StoriesViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.storiesTable.indexPathForRow(at: location) else { return nil }
        guard let cell = self.storiesTable.cellForRow(at: indexPath)
            as? StoryTableViewCell else { return nil }
        return self.safariViewForItem(
            at: URL(string: cell.story?.url ?? ""), defaultUrl: HackerNewsService.HOME_URL)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
    
}

// MARK: StoryTableViewCellDelegate

extension StoriesViewController: StoryTableViewCellDelegate {
    
    func didPressCommentsButton(_ cell: StoryTableViewCell) {
        let url = URL(string: HackerNewsService.COMMENTS_URL + "\(cell.story?.id ?? "1")")
        guard let safariVC =
            self.safariViewForItem(at: url, defaultUrl: HackerNewsService.HOME_URL) else { return }
        self.present(safariVC, animated: true, completion: nil)
    }
    
}
