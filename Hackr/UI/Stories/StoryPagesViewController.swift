//
//  StoryPagesViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/10/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

final class StoryPagesViewController: UIViewController {
  enum Constants {
    static let settingsIcon = UIImage(named: "ic-settings")
  }

  // MARK: - Private Properties

  private var hackrTabBarController: UITabBarController!
  private let storyTypes = HackerNewsItemType.allCases
  private let storyTypeToTitle: [HackerNewsItemType: String] =
    [.topStories: "Top", .newStories: "New", .bestStories: "Best"]
  private let storyTypeToIcon: [HackerNewsItemType: String] =
    [.topStories: "topStories", .newStories: "newStories", .bestStories: "bestStories"]
  private var storyPages: [StoriesViewController] = []
  private var lastPendingViewControllerIndex = 0
  private var currentViewControllerIndex = 0

  private var searchController: UISearchController = {
    let controller = UISearchController(searchResultsController: nil)
    controller.searchBar.tintColor = UIColor.hackerNewsOrange
    return controller
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = storyTypes[0].rawValue

    let settingsButton = UIBarButtonItem(image: Constants.settingsIcon,
                                         style: .plain,
                                         target: self,
                                         action: #selector(settingsButtonTapped(sender:)))
    settingsButton.tintColor = UIColor.hackerNewsOrange
    navigationItem.rightBarButtonItem = settingsButton

//    navigationItem.hidesSearchBarWhenScrolling = false
//    searchController.searchResultsUpdater = storyPages[currentViewControllerIndex]
//    storyPages[currentViewControllerIndex].searchController = searchController
//    navigationItem.searchController = searchController

    var viewControllers: [UIViewController] = []
    
    // Hacker News Stories
    // Order: New, Top, Best
    for i in 0...storyTypes.count - 1 {
      let storyType = storyTypes[i]
      let storiesVC = StoriesViewController(for: storyType)
      let tabBarIcon = UIImage(named: storyTypeToIcon[storyType]!)
      storiesVC.tabBarItem =
        UITabBarItem(title: storyTypeToTitle[storyType], image: tabBarIcon, tag: i)
      viewControllers.append(storiesVC)
    }
    
    // Saved Stories
    let savedStoriesVC = SavedStoriesViewController()
    savedStoriesVC.tabBarItem =
      UITabBarItem(title: "Saved", image: UIImage(named: "savedStories"), tag: 3)
    viewControllers.append(savedStoriesVC)
    
    hackrTabBarController = UITabBarController()
    hackrTabBarController.delegate = self
    hackrTabBarController.viewControllers = viewControllers
    hackrTabBarController.tabBar.tintColor = UIColor.hackerNewsOrange
    addChild(hackrTabBarController)
    view.addSubview(hackrTabBarController.view)
  }

  // MARK: - Private

  @objc private func settingsButtonTapped(sender: UIBarButtonItem) {
    let navController = HackrNavigationController()
    navController.viewControllers = [SettingsViewController()]
    present(navController, animated: true, completion: nil)
  }
}

// MARK: - UITabBarControllerDelegate

extension StoryPagesViewController: UITabBarControllerDelegate {
  func tabBarController(
    _ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    let selectedIndex = tabBarController.selectedIndex
    if selectedIndex == 3 {
      navigationItem.title = "Saved Stories"
      return
    }
    navigationItem.title = storyTypes[tabBarController.selectedIndex].rawValue
  }
}
