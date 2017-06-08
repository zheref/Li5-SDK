//
//  PageViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit


public enum PaginationDirection {
    case Horizontal
    case Vertical
}


enum ScrollDirection {
    case none
    case right
    case left
    case up
    case down
}


internal protocol PaginatorViewControllerProtocol {
    
    var datasource: PaginatorViewControllerDataSource? { get set }
    var delegate: PaginatorViewControllerDelegate? { get set }
    
    var preloadedViewControllers: [UIViewController] { get set }
    
    var previousViewController: UIViewController? { get set }
    var currentViewController: UIViewController? { get set }
    var nextViewController: UIViewController? { get set }
    
    var direction: PaginationDirection { get set }
    var bounces: Bool { get set }
    
}


internal class PaginatorViewController : UIViewController, PaginatorViewControllerProtocol {
    
    // MARK: - PUBLIC INTERFACE
    
    // MARK: Stored Properties
    
    var datasource: PaginatorViewControllerDataSource?
    var delegate: PaginatorViewControllerDelegate?
    
    var previousViewController: UIViewController?
    var currentViewController: UIViewController?
    var nextViewController: UIViewController?
    
    
    var direction = PaginationDirection.Horizontal
    var bounces = true
    
    
    var preloadedViewControllers: [UIViewController] {
        get { return _preloadedViewControllers }
        set {
            log.debug("Setting preloaded view controllers")
            
            if let firstVC = newValue.first {
                if currentPageIndex != firstVC.scrollPageIndex {
                    currentPageIndex = firstVC.scrollPageIndex
                }
                
                fullySwitchedPageIndex = currentPageIndex
                currentViewController = firstVC
                
                if let _ = datasource {
                    log.debug("PT: Datasource present. Will set preloaded view controllers by also preloading the next ones.")
                    
                    _preloadedViewControllers = newValue
                } else {
                    log.debug("Datasource not present. Will set preloaded view controllers just as they were passed.")
                    _preloadedViewControllers = newValue
                    
                    for index in currentPageIndex...(_preloadedViewControllers.count - 1) {
                        _preloadedViewControllers[index].scrollPageIndex = index
                    }
                }
            }
        }
    }
    
    
    // MARK: Initializers
    
    init(withDirection direction: PaginationDirection) {
        operationQueue = OperationQueue()
        super.init(nibName: "PageViewController", bundle: Bundle(for: PaginatorViewController.self))
        self.direction = direction
        
        self.reset()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        operationQueue = OperationQueue()
        super.init(coder: aDecoder)
        self.reset()
    }
    
    
    init() {
        operationQueue = OperationQueue()
        super.init(nibName: "PageViewController", bundle: Bundle(for: PaginatorViewController.self))
        self.reset()
    }
    
    // MARK: - PRIVATE INTERFACE
    
    // MARK: Stored Properties
    
    private var _preloadedViewControllers = [UIViewController]()
    
    // MARK: Thread related
    
    var operationQueue: OperationQueue
    var preloading = false
    
    // MARK: Behavior
    
    var scrollDirection: ScrollDirection?
    
    var currentPageIndex: Int = 0 {
        didSet {
            log.verbose("Set new current page index to: \(currentPageIndex)")
            
            if currentPageIndex >= pagesCount {
                log.verbose("Restoring page index to a safe position since it is out of bounds")
                currentPageIndex = pagesCount - 1
            }
            
            updateScrollViewContent()
            
            fullySwitchedPageIndex = currentPageIndex // ???
        }
    }
    
    var fullySwitchedPageIndex: Int = 0 // ???
    var pageLength: CGFloat? // No idea
    var lastContentOffset: CGFloat? // No idea
    
    // MARK: UI Elements
    
    var containerScrollView: UIScrollView!
    
    // MARK: - COMPUTED PROPERTIES
    
    private var pagesCount: Int {
        if let _ = datasource,
            let last = _preloadedViewControllers.last {
            return max(last.scrollPageIndex + 1, _preloadedViewControllers.count)
        } else {
            return _preloadedViewControllers.count
        }
    }
    
    
    // MARK: Routines
    
    
    func reset() {
        _preloadedViewControllers = [UIViewController]()
        datasource = nil
        bounces = true
        
        fullySwitchedPageIndex = 0
        
        operationQueue = OperationQueue()
        operationQueue.name = "PageVC Queue"
    }
    
    
    func setup() {
        automaticallyAdjustsScrollViewInsets = false
        
        containerScrollView = UIScrollView(frame: view.bounds)
        
        containerScrollView.isPagingEnabled = true
        containerScrollView.alwaysBounceVertical = false
        
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.showsVerticalScrollIndicator = false
        
        containerScrollView.delegate = self
        containerScrollView.bounces = false
        
        pageLength = direction == .Vertical ? view.bounds.size.height : view.bounds.size.width
        
        view.addSubview(containerScrollView)
    }
    
    
    func updateScrollViewContent() {
        
        log.verbose("Updating scroll view content (?)...")
        
        containerScrollView.delegate = nil
        
        pageLength = direction == .Vertical ? view.bounds.size.height : view.bounds.size.width // Do we need to reupdate this???
        
        containerScrollView.contentSize = CGSize(width: direction == .Horizontal ? CGFloat(pagesCount) * view.bounds.size.width : 1.0,
                                                 height: direction == .Vertical ? CGFloat(pagesCount) * view.bounds.size.height : 1.0)
        
        containerScrollView.contentOffset = CGPoint(x: direction == .Horizontal ? CGFloat(currentPageIndex) * view.bounds.size.width : 0.0,
                                                    y: direction == .Vertical ? CGFloat(currentPageIndex) * view.bounds.size.height : 0.0)
        
        containerScrollView.delegate = self
    }
    
    
    func setFullySwitchedPage(pageIndex: Int) {
        log.debug("Running setFullySwitchedPage...")
        
        if fullySwitchedPageIndex != pageIndex {
            
            if fullySwitchedPageIndex < pagesCount {
                
                let fromPageIndex = currentPageIndex
                
                // This method is super confusing
            }
            
        }
    }
    
    
    /// Relayout views to make actual UI nest already preloaded view controllers
    func relayout() {
        log.verbose("Running relayout...")
        
        if _preloadedViewControllers.isEmpty {
            log.warning("No preloaded view controllers when running relayout. Won't present anything.")
        }
        
        for vc in _preloadedViewControllers {
            present(viewController: vc)
        }
        
        updateScrollViewContent()
    }
    
    
    /// Nest the given actual view controller view to actual parent UI (ScrollView) to present it
    /// - Parameter viewController: The view controller to present
    func present(viewController: UIViewController) {
        log.verbose("Presenting page view controller with product index: \(viewController.scrollPageIndex)")
        
        addChildViewController(viewController)
        
        let nextFrame = CGRect(x: direction == .Vertical ? view.bounds.origin.x : CGFloat(viewController.scrollPageIndex) * view.bounds.size.width,
                               y: direction == .Horizontal ? view.bounds.origin.y : CGFloat(viewController.scrollPageIndex) * view.bounds.size.height,
                               width: view.bounds.size.width,
                               height: view.bounds.size.height)
        
        viewController.view.frame = nextFrame
        containerScrollView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    
    func preloadViewController(withIndex productIndex: Int) {
        guard let datasource = datasource, preloading else {
            if preloading {
                log.warning("Preloading is already in process")
            } else {
                log.warning("DataSource is nil for PageViewController")
            }
            return
        }
        
        if isViewControllerPreloaded(forIndex: productIndex) {
            log.verbose("Not preloading since vc for product index: \(index) is already in memory")
        }
        
        preloading = true
        
        if let preloadingViewController = datasource.viewControllerViewController(at: productIndex) {
            preloadingViewController.scrollPageIndex = productIndex
            
            var vcs = [UIViewController]()
            
            if scrollDirection == .left || scrollDirection == .down {
                if let previousVC = previousViewController {
                    vcs.append(previousVC)
                }
                
                if let currentVC = currentViewController {
                    vcs.append(currentVC)
                }
                
                vcs.append(preloadingViewController)
            } else {
                vcs.append(preloadingViewController)
                
                if let currentVC = currentViewController {
                    vcs.append(currentVC)
                }
                
                if let previousVC = previousViewController {
                    vcs.append(previousVC)
                }
            }
            
            _preloadedViewControllers = vcs
            
            if preloadingViewController.parent == nil {
                log.debug("Presenting preloading view controller with product index: \(productIndex)")
                present(viewController: preloadingViewController)
            }
            
            //[self __cleanViewControllers];
            preloading = false
        } else {
            preloading = false
        }
    }
    
    
    /// Checks whether a view controller for the given product index is already preloaded or not
    /// - Parameter productIndex: Index of all fetched products (regardless of if it is in memory preloaded view controllers)
    /// - Returns: Returns true if found a preloaded view controller matching product index or false if no matches.
    func isViewControllerPreloaded(forIndex productIndex: Int) -> Bool {
        for vc in _preloadedViewControllers {
            if vc.scrollPageIndex == productIndex {
                return true
            }
        }
        
        return false
    }
    
    
    /// Look for the in memory preloaded view controller matching the product index
    /// - Parameter productIndex: Index (starting from 0) of all fetched products (regardless of if it is in memory preloaded view controllers)
    /// - Returns: Returns the preloaded view controller matching product index or nil if no matches.
    func viewControllerMatching(productIndex: Int) -> UIViewController? {
        for vc in _preloadedViewControllers {
            if vc.scrollPageIndex == productIndex {
                return vc
            }
        }
        
        return nil
    }
    
    
    /// Gets or creates a page view controller for the given index
    /// - Parameter index: Index (starting from 0) of all fetched products (regardless of if it is in memory preloaded view controllers)
    /// - Returns: Page view controller matching index of product
    func getOrCreateViewController(forIndex index: Int) -> UIViewController? {
        log.verbose("Trying to get page vc for index \(index)")
        
        if let matchingViewController = viewControllerMatching(productIndex: index) {
            log.debug("Page vc matching index is already in memory. Returning it...")
            return matchingViewController
        }
        
        log.debug("No page vc matching index. Creating new instance from scratch...")
        
        guard let datasource = datasource else {
            log.warning("DataSource is nil for PageViewController")
            return nil
        }
        
        if let newViewController = datasource.viewControllerViewController(at: index) {
            newViewController.scrollPageIndex = index
            _preloadedViewControllers.append(newViewController)
            return newViewController
        } else {
            return nil
        }
    }
    
    
    /// Cleans view controllers from the child view controllers when it is detected they're not inside
    /// the range of the in memory preloaded view controllers any longer (and it's not the currently
    /// displayed view controller).
    func cleanViewControllers() {
        log.verbose("Cleaning page view controllers...")
        
        for childVC in childViewControllers {
            if _preloadedViewControllers.contains(childVC) == false {
                if currentViewController != childVC {
                    log.debug("Getting rid of unnecessary child view controller")
                    childVC.view.removeFromSuperview()
                    childVC.removeFromParentViewController()
                }
            }
        }
    }
    
    
    func preloadPreviousViewController(to vcs: [UIViewController]) -> [UIViewController] {
        guard let datasource = datasource else {
            log.warning("Datasource not available. Skipping preloading previous vcs.")
            return vcs
        }
        
        if let firstVC = vcs.first {
            var controllers = [UIViewController]()
            
            if let previousVC = datasource.viewController(before: firstVC) {
                previousVC.scrollPageIndex = firstVC.scrollPageIndex - 1
                
                controllers.append(previousVC)
            }
            
            controllers.append(contentsOf: vcs)
            
            return controllers
        } else {
            return vcs
        }
    }
    
    
    func preloadNextViewController(to vcs: [UIViewController]) -> [UIViewController] {
        guard let datasource = datasource else {
            log.warning("Datasource not available. Skipping preloading next vcs.")
            return vcs
        }
        
        if let lastVC = vcs.last {
            var controllers = [UIViewController]()
            
            controllers.append(contentsOf: vcs)
            
            if let nextVC = datasource.viewController(after: lastVC) {
                nextVC.scrollPageIndex = lastVC.scrollPageIndex + 1
                
                controllers.append(nextVC)
            }
            
            return controllers
        } else {
            return vcs
        }
    }
    
    
    // MARK: LIFECYCLE
    
    
    override public func viewDidLoad() {
        log.debug("PageViewController did load :)")
        super.viewDidLoad()
        
        setup()
    }
    
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    
    override public func viewDidAppear(_ animated: Bool) {
        log.debug("PageViewController did appear")
        super.viewDidAppear(animated)
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    
    override public func viewDidDisappear(_ animated: Bool) {
        log.debug("PageViewController did disappear")
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override public var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    
    public override func viewDidLayoutSubviews() {
        relayout()
    }
    
    
}


extension PaginatorViewController : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}
