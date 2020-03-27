//
//  File.swift
//  Hackr
//
//  Created by Alejandrina Patron on 3/22/20.
//  Copyright © 2020 Alejandrina Patron. All rights reserved.
//

import UIKit

class SavedStoriesViewController: UIViewController {

  private var storiesTable = UITableView()
  private var savedStories = [HackerNewsStory]()

  override func viewDidLoad() {
    super.viewDidLoad()
    storiesTable.delegate = self
    storiesTable.dataSource = self
    storiesTable.register(StoryTableViewCell.self,
    forCellReuseIdentifier: StoryTableViewCell.identifier)
    view.addSubview(storiesTable)
    storiesTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
    right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0,
    paddingRight: 0, width: 0, height: 0, enableInsets: false)
    storiesTable.tableFooterView = UIView(frame: .zero)

    // TODO: Add empty view when user hasn't saved stories yet.
    SavedStoriesController.registerListener(self)
    savedStories = SavedStoriesController.getAllSavedStories()
  }
}

// MARK: UITableViewDelegate

extension SavedStoriesViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let saveStoryAction = UIContextualAction(style: .destructive, title: "Remove", handler: {
      action, view, completionHandler in
      SavedStoriesController.unsaveStory(at: indexPath.row, self.savedStories[indexPath.row])
      completionHandler(true)
    })
    return UISwipeActionsConfiguration(actions: [saveStoryAction])
  }
}

// MARK: UITableViewDataSource

extension SavedStoriesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return savedStories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: StoryTableViewCell.identifier) as! StoryTableViewCell
    cell.delegate = self
    cell.story = savedStories[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    storiesTable.deselectRow(at: indexPath, animated: true)
    let selectedStory = savedStories[indexPath.row]
    if let url = URL(string: selectedStory.url ?? "") {
      guard let safariVC =
        safariViewForItem(at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
      present(safariVC, animated: true, completion: nil)
    }
  }
}

extension SavedStoriesViewController: StoryTableViewCellDelegate {
  func didPressCommentsButton(_ cell: StoryTableViewCell) {
    let url = URL(string: HackerNewsConstants.COMMENTS_URL + "\(cell.story?.id ?? "1")")
    guard let safariVC =
      safariViewForItem(at: url, defaultUrl: HackerNewsConstants.HOME_URL) else { return }
    present(safariVC, animated: true, completion: nil)
  }
}

extension SavedStoriesViewController: SavedStoriesControllerDelegate {
  func savedStoriesDidChange() {
    savedStories = SavedStoriesController.getAllSavedStories()
    storiesTable.reloadData()
  }
}
