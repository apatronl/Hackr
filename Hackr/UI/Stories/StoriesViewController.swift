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

  // MARK: - Private Properties

  private var storiesTable = UITableView()
  private var stories = [HackerNewsStory]()
  private var refresher = UIRefreshControl()
  private var hnService: HackerNewsService!
  private var darkModeState: DarkModeState = .off
  private(set) var storyType: HackerNewsItemType

  private var spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    spinner.color = UIColor.hackerNewsOrange
    spinner.autoresizingMask =
      [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
    return spinner
  }()

  // MARK: - Life Cycle

  public init(for storyType: HackerNewsItemType) {
    self.storyType = storyType
    self.hnService = HackerNewsService(type: storyType, maxStoriesToLoad: 20)
    darkModeState = DarkModeController.getDarkModeState()
    super.init(nibName: nil, bundle: nil)
    DarkModeController.addListener(self)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpViewForDarkModeState(darkModeState)
    storiesTable.tableFooterView = UIView(frame: CGRect.zero)
    storiesTable.dataSource = self
    storiesTable.delegate = self
    storiesTable.register(StoryTableViewCell.self,
                             forCellReuseIdentifier: StoryTableViewCell.identifier)

    refresher.addTarget(self, action: #selector(refreshStories), for: .valueChanged)
    refresher.tintColor = UIColor.hackerNewsOrange
    storiesTable.refreshControl = refresher
    self.view.addSubview(storiesTable)
    storiesTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
                        right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0,
                        paddingRight: 0, width: 0, height: 0, enableInsets: false)

    spinner.center = view.center
    view.addSubview(spinner)
    spinner.startAnimating()
    self.hnService.getStories(completion: { stories, error in
      DispatchQueue.main.async {
        self.spinner.stopAnimating()
        if let error = error {
          self.showErrorMessage(error)
          return
        }
        if let stories = stories {
          self.stories += stories
          self.storiesTable.reloadData()
        }
      }
    })
  }

  override func viewDidAppear(_ animated: Bool) {
    if (traitCollection.forceTouchCapability == .available) {
      self.registerForPreviewing(with: self, sourceView: self.storiesTable)
    }
  }

  // MARK: - Private

  private func setUpViewForDarkModeState(_ state: DarkModeState) {
    self.view.backgroundColor = state == .on ? UIColor.black : UIColor.white
    storiesTable.backgroundColor = state == .on ? UIColor.darkModeGray : UIColor.white
    storiesTable.reloadData()
  }

  @objc private func refreshStories() {
    self.hnService.getStories(completion: { stories, error in
      DispatchQueue.main.async {
        self.refresher.endRefreshing()
        if let error = error {
          self.showErrorMessage(error)
          return
        }
        guard let stories = stories else { return }
        self.stories = stories
        self.storiesTable.reloadData()
      }
    })
  }
}

// MARK: UITableViewDelegate

extension StoriesViewController: UITableViewDelegate {}

// MARK: UITableViewDataSource

extension StoriesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: StoryTableViewCell.identifier) as! StoryTableViewCell
    cell.delegate = self
    if (!refresher.isRefreshing) {
        cell.story = self.stories[indexPath.row]
    }
    cell.darkModeState = darkModeState
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.refresher.isRefreshing { return }
    if let url = URL(string: self.stories[indexPath.row].url ?? "") {
      guard let safariVC = self.safariViewForItem(
        at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
      self.present(safariVC, animated: true, completion: nil)
    }
    self.storiesTable.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    if indexPath.row == self.stories.count - 1 {
      self.hnService.loadMoreStories(completion: { stories, error in
        DispatchQueue.main.async {
          if let error = error {
            self.showErrorMessage(error)
            return
          }
          guard let stories = stories else { return }
          if stories.isEmpty { return }
          self.stories += stories
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
        at: URL(string: cell.story?.url ?? ""), defaultUrl: HackerNewsConstants.HOME_URL)
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    self.present(viewControllerToCommit, animated: true, completion: nil)
  }
}

// MARK: StoryTableViewCellDelegate

extension StoriesViewController: StoryTableViewCellDelegate {
  func didPressCommentsButton(_ cell: StoryTableViewCell) {
    let url = URL(string: HackerNewsConstants.COMMENTS_URL + "\(cell.story?.id ?? "1")")
    guard let safariVC =
      self.safariViewForItem(at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
    self.present(safariVC, animated: true, completion: nil)
  }
}

// MARK: DarkModeDelegate

extension StoriesViewController: DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState) {
    darkModeState = state
    setUpViewForDarkModeState(state)
  }
}
