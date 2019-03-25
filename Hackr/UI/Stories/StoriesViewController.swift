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

  enum Constants {
    static let tableFooterViewHeight: CGFloat = 50.0
    static let tableSpinnerHeight = tableFooterViewHeight / 2
  }

  // MARK: - Private Properties

  private var storiesTable = UITableView()
  private var stories = [HackerNewsStory]()
  private var queriedStories = [HackerNewsStory]()
  private var searchQueryActive = false
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

  private var tableSpinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .white)
    spinner.color = UIColor.hackerNewsOrange
    spinner.autoresizingMask =
      [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
    return spinner
  }()

  // MARK: - Life Cycle

  public init(for storyType: HackerNewsItemType) {
    self.storyType = storyType
    hnService = HackerNewsService(type: storyType, maxStoriesToLoad: 20)
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
    view.addSubview(storiesTable)
    storiesTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
                        right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0,
                        paddingRight: 0, width: 0, height: 0, enableInsets: false)

    spinner.center = view.center
    view.addSubview(spinner)
    spinner.startAnimating()
    hnService.getStories(completion: { stories, error in
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
      registerForPreviewing(with: self, sourceView: storiesTable)
    }
  }

  // MARK: - Private

  private func setUpViewForDarkModeState(_ state: DarkModeState) {
    view.backgroundColor = state == .on ? UIColor.black : UIColor.white
    storiesTable.backgroundColor = state == .on ? UIColor.darkModeGray : UIColor.white
    storiesTable.reloadData()
  }

  private func setupTableViewSpinner() {
    storiesTable.tableFooterView = UIView(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: storiesTable.frame.width,
                                                        height: Constants.tableFooterViewHeight))
    tableSpinner.frame = CGRect(x: storiesTable.frame.width / 2 - Constants.tableSpinnerHeight / 2,
                                y: Constants.tableSpinnerHeight / 2,
                                width: Constants.tableSpinnerHeight,
                                height: Constants.tableSpinnerHeight)
    storiesTable.tableFooterView?.addSubview(tableSpinner)
    tableSpinner.startAnimating()
  }

  @objc private func refreshStories() {
    hnService.getStories(completion: { stories, error in
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
    if searchQueryActive {
      return queriedStories.count
    }
    return stories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: StoryTableViewCell.identifier) as! StoryTableViewCell
    cell.delegate = self
    if (!refresher.isRefreshing) {
      cell.story = searchQueryActive ? queriedStories[indexPath.row] : stories[indexPath.row]
    }
    cell.darkModeState = darkModeState
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if refresher.isRefreshing { return }
    let selectedStory = searchQueryActive ? queriedStories[indexPath.row] : stories[indexPath.row]
    if let url = URL(string: selectedStory.url ?? "") {
      guard let safariVC =
        safariViewForItem(at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
      present(safariVC, animated: true, completion: nil)
    }
    storiesTable.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                 forRowAt indexPath: IndexPath) {
    guard !searchQueryActive else { return }
    if indexPath.row == stories.count - 1 {
      setupTableViewSpinner()
      hnService.loadMoreStories(completion: { stories, error in
        DispatchQueue.main.async {
          self.tableSpinner.stopAnimating()
          self.storiesTable.tableFooterView = UIView(frame: CGRect.zero)
          if let error = error {
            self.showErrorMessage(error)
            return
          }
          guard let stories = stories, !stories.isEmpty else { return }
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
    guard let indexPath = storiesTable.indexPathForRow(at: location),
      let cell =  storiesTable.cellForRow(at: indexPath) as? StoryTableViewCell else { return nil }
    return safariViewForItem(at: URL(string: cell.story?.url ?? ""),
                             defaultUrl: HackerNewsConstants.HOME_URL)
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true, completion: nil)
  }
}

// MARK: StoryTableViewCellDelegate

extension StoriesViewController: StoryTableViewCellDelegate {
  func didPressCommentsButton(_ cell: StoryTableViewCell) {
    let url = URL(string: HackerNewsConstants.COMMENTS_URL + "\(cell.story?.id ?? "1")")
    guard let safariVC =
      safariViewForItem(at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
    present(safariVC, animated: true, completion: nil)
  }
}

// MARK: DarkModeDelegate

extension StoriesViewController: DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState) {
    darkModeState = state
    setUpViewForDarkModeState(state)
  }
}

// MARK: - UISearchResultsUpdating

extension StoriesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if let query = searchController.searchBar.text, !query.isEmpty {
      queriedStories = stories.filter {
        return $0.title?.lowercased().contains(query.lowercased()) ?? false
      }
      searchQueryActive = true
    } else {
      searchQueryActive = false
      queriedStories.removeAll()
    }
    storiesTable.reloadData()
  }
}
