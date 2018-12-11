//
//  StoryPagesViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/10/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

class StoryPagesViewController: UIViewController {
    
    var pagesViewController: UIPageViewController!
    let storyTypes = HackerNewsItemType.allCases
    var storyPages: [StoriesViewController] = []
    var lastPendingViewControllerIndex = 0
    var currentViewControllerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = storyTypes[0].rawValue
        self.pagesViewController =
            UIPageViewController(transitionStyle: .scroll,
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

}

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
        }
    }
}

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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
