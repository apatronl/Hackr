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

  private var pagesViewController: UIPageViewController!
  private var pageControl: UIPageControl!
  private let storyTypes = HackerNewsItemType.allCases
  private var storyPages: [StoriesViewController] = []
  private var lastPendingViewControllerIndex = 0
  private var currentViewControllerIndex = 0

  private var searchController: UISearchController = {
    let controller = UISearchController(searchResultsController: nil)
    controller.searchBar.tintColor = UIColor.hackerNewsOrange
    controller.dimsBackgroundDuringPresentation = false
    return controller
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    DarkModeController.addListener(self)
    setUpViewForDarkModeState(DarkModeController.getDarkModeState())
    navigationItem.title = storyTypes[0].rawValue

    pageControl =
      UIPageControl(frame: CGRect(x: 35, y: (navigationController?.navigationBar.frame.height)! / 2,
                    width: 0, height: 0))
    pageControl.numberOfPages = 3
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.hackerNewsOrange
    navigationController?.navigationBar.addSubview(pageControl)

    let settingsButton = UIBarButtonItem(image: Constants.settingsIcon,
                                         style: .plain,
                                         target: self,
                                         action: #selector(settingsButtonTapped(sender:)))
    settingsButton.tintColor = UIColor.hackerNewsOrange
    navigationItem.rightBarButtonItem = settingsButton

    pagesViewController = UIPageViewController(transitionStyle: .scroll,
                                               navigationOrientation: .horizontal,
                                               options: nil)

    for storyType in storyTypes {
      storyPages.append(StoriesViewController(for: storyType))
    }
    pagesViewController.setViewControllers([storyPages[currentViewControllerIndex]],
                                           direction: .forward, animated: true, completion: nil)
    pagesViewController.dataSource = self
    pagesViewController.delegate = self

    addChild(pagesViewController)
    view.addSubview(pagesViewController.view)

    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.searchResultsUpdater = storyPages[currentViewControllerIndex]
    navigationItem.searchController = searchController
  }

  func indexOfViewController(_ viewController: StoriesViewController) -> Int {
    return storyTypes.index(of: viewController.storyType) ?? NSNotFound
  }

  private func setUpViewForDarkModeState(_ state: DarkModeState) {
    view.backgroundColor = state == .on ? UIColor.black : UIColor.white
    navigationController?.navigationBar.barStyle = state == .on ? .black : .default
    navigationController?.view.backgroundColor = state == .on ? UIColor.darkModeGray : UIColor.white
  }

  // MARK: - Private

  @objc private func settingsButtonTapped(sender: UIBarButtonItem) {
    let navController = HackrNavigationController()
    navController.viewControllers = [SettingsViewController()]
    present(navController, animated: true, completion: nil)
  }
}

// MARK: - UIPageViewControllerDelegate

extension StoryPagesViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController,
                          willTransitionTo pendingViewControllers: [UIViewController]) {
    if let vc = pendingViewControllers[0] as? StoriesViewController {
      lastPendingViewControllerIndex = indexOfViewController(vc)
    }
  }

  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    if completed {
      currentViewControllerIndex = lastPendingViewControllerIndex
      navigationItem.title = storyTypes[currentViewControllerIndex].rawValue
      pageControl.currentPage = currentViewControllerIndex
      searchController.searchResultsUpdater = storyPages[currentViewControllerIndex]
    }
  }
}

// MARK: - UIPageViewControllerDataSource

extension StoryPagesViewController: UIPageViewControllerDataSource {
  func pageViewController(
      _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController) -> UIViewController? {
    var index = indexOfViewController(viewController as! StoriesViewController)
    guard index != 0 && index != NSNotFound else { return nil }
    index -= 1
    return storyPages[index]
  }

  func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController) -> UIViewController? {
    var index = indexOfViewController(viewController as! StoriesViewController)
    guard index != NSNotFound else { return nil }
    index += 1
    guard index != storyPages.count else { return nil }
    return storyPages[index]
  }
}

// MARK: - DarkModeDelegate

extension StoryPagesViewController: DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState) {
    setUpViewForDarkModeState(state)
  }
}
