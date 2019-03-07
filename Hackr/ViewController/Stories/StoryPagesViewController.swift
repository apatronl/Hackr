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

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    DarkModeController.addListener(self)
    setUpViewForDarkModeState(DarkModeController.getDarkModeState())
    self.navigationItem.title = storyTypes[0].rawValue

    self.pageControl =
        UIPageControl(
            frame: CGRect(x: 35,
                          y: (self.navigationController?.navigationBar.frame.height)! / 2,
                          width: 0, height: 0))
    pageControl.numberOfPages = 3
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.hackerNewsOrange
    self.navigationController?.navigationBar.addSubview(pageControl)

    let settingsButton =
      UIBarButtonItem(image: Constants.settingsIcon,
                      style: .plain,
                      target: self,
                      action: #selector(settingsButtonTapped(sender:)))
    settingsButton.tintColor = UIColor.hackerNewsOrange
    self.navigationItem.rightBarButtonItem = settingsButton
    
    self.pagesViewController = UIPageViewController(transitionStyle: .scroll,
                                                    navigationOrientation: .horizontal,
                                                    options: nil)

    for storyType in storyTypes {
        self.storyPages.append(StoriesViewController(for: storyType))
    }
    self.pagesViewController.setViewControllers([self.storyPages[0]],
                                                direction: .forward,
                                                animated: true,
                                                completion: nil)
    self.pagesViewController.dataSource = self
    self.pagesViewController.delegate = self

    self.addChild(self.pagesViewController)
    self.view.addSubview(self.pagesViewController.view)
  }

  func indexOfViewController(_ viewController: StoriesViewController) -> Int {
    return storyTypes.index(of: viewController.storyType) ?? NSNotFound
  }

  private func setUpViewForDarkModeState(_ state: DarkModeState) {
    self.view.backgroundColor = state == .on ? UIColor.black : UIColor.white
    self.navigationController?.navigationBar.barStyle = state == .on ? .black : .default
    self.navigationController?.view.backgroundColor =
      state == .on ? UIColor.darkModeGray : UIColor.white
  }

  // MARK: - Private

  @objc private func settingsButtonTapped(sender: UIBarButtonItem) {
    let navController = HackrNavigationController()
    navController.viewControllers = [SettingsViewController()]
    self.present(navController, animated: true, completion: nil)
  }
}

// MARK: - UIPageViewControllerDelegate

extension StoryPagesViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController,
                          willTransitionTo pendingViewControllers: [UIViewController]) {
    if let vc = pendingViewControllers[0] as? StoriesViewController {
        self.lastPendingViewControllerIndex = indexOfViewController(vc)
    }
  }

  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    if completed {
        self.currentViewControllerIndex = self.lastPendingViewControllerIndex
        self.navigationItem.title = storyTypes[self.currentViewControllerIndex].rawValue
        self.pageControl.currentPage = self.currentViewControllerIndex
    }
  }
}

// MARK: - UIPageViewControllerDataSource

extension StoryPagesViewController: UIPageViewControllerDataSource {
  func pageViewController(
      _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController) -> UIViewController? {
    var index = self.indexOfViewController(viewController as! StoriesViewController)
    if (index == 0) || (index == NSNotFound) {
        return nil
    }
    index -= 1
    return self.storyPages[index]
  }

  func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController) -> UIViewController? {
    var index = self.indexOfViewController(viewController as! StoriesViewController)
    if index == NSNotFound {
        return nil
    }
    index += 1
    if index == self.storyPages.count {
        return nil
    }
    return self.storyPages[index]
  }
}

extension StoryPagesViewController: DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState) {
    setUpViewForDarkModeState(state)
  }
}
