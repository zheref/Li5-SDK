//
//  PaginatorViewController.swift
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
    
    weak var datasource: PaginatorViewControllerDataSource?
    
    var previousViewController: UIViewController?
    var currentViewController: UIViewController?
    var nextViewController: UIViewController?
    
    
    var direction = PaginationDirection.Horizontal
    var bounces = true
    
    
    var preloadedViewControllers: [UIViewController] {
        get { return _preloadedViewControllers }
        set {
            if let firstVC = newValue.first {
                if currentPageIndex != firstVC.scrollPageIndex {
                    currentPageIndex = firstVC.scrollPageIndex
                }
                
                currentViewController = firstVC
                
                if let _ = datasource {
                    let preloadedViewControllersPlusNextOne = preloadNextViewController(to: newValue)
                    let preloadedViewControllersPlusSurroundings = preloadPreviousViewController(to: preloadedViewControllersPlusNextOne)
                    log.debug("Preloaded viewcontrollers! Now we have \(preloadedViewControllersPlusSurroundings.count) in queue")
                    _preloadedViewControllers = preloadedViewControllersPlusSurroundings
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
        super.init(nibName: "PaginatorViewController", bundle: Bundle(for: PaginatorViewController.self))
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
        super.init(nibName: "PaginatorViewController", bundle: Bundle(for: PaginatorViewController.self))
        self.reset()
    }
    
    // MARK: - PRIVATE INTERFACE
    
    // MARK: Stored Properties
    
    private var _preloadedViewControllers = [UIViewController]() {
        didSet {
            logPreloadedViewControllers()
        }
    }
    
    // MARK: Thread related
    
    var operationQueue: OperationQueue
    fileprivate var preloading = false
    
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
        }
    }
    
    var pageLength: CGFloat = 0.0
    var lastContentOffset: CGFloat = 0.0
    
    // MARK: UI Elements
    
    var containerScrollView: UIScrollView!
    
    // MARK: - COMPUTED PROPERTIES
    
    fileprivate var pagesCount: Int {
        if let _ = datasource,
            let last = _preloadedViewControllers.last {
            return max(last.scrollPageIndex + 1, _preloadedViewControllers.count)
        } else {
            return _preloadedViewControllers.count
        }
    }
    
    
    fileprivate var directedToLeftOrDown: Bool {
        return scrollDirection == .left || scrollDirection == .down
    }
    
    
    fileprivate var scrollViewContentOffset: CGFloat {
        return direction == .Vertical ?
            containerScrollView.contentOffset.y : containerScrollView.contentOffset.x
    }
    
    
    // MARK: Routines
    
    
    func reset() {
        _preloadedViewControllers = [UIViewController]()
        datasource = nil
        bounces = true
        
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
        containerScrollView.delegate = nil
        
        pageLength = direction == .Vertical ? view.bounds.size.height : view.bounds.size.width // Do we need to reupdate this???
        
        containerScrollView.contentSize = CGSize(width: direction == .Horizontal ? CGFloat(pagesCount) * view.bounds.size.width : 1.0,
                                                 height: direction == .Vertical ? CGFloat(pagesCount) * view.bounds.size.height : 1.0)
        
        containerScrollView.contentOffset = CGPoint(x: direction == .Horizontal ? CGFloat(currentPageIndex) * view.bounds.size.width : 0.0,
                                                    y: direction == .Vertical ? CGFloat(currentPageIndex) * view.bounds.size.height : 0.0)
        
        containerScrollView.delegate = self
    }
    
    
    func moveTo(pageIndex targetPageIndex: Int) {
        log.verbose("Moved to page index: \(targetPageIndex)...")
        
        if currentPageIndex != targetPageIndex {
            
            if currentPageIndex < pagesCount {
                
                let originPageIndex = currentPageIndex
                
                // Update references
                previousViewController = getOrCreateViewController(forIndex: originPageIndex)
                currentViewController = getOrCreateViewController(forIndex: targetPageIndex)
                
                if let currentVC = currentViewController,
                    currentVC.parent == nil {
                    
                    present(viewController: currentVC)
                }
                
                if let previousVC = previousViewController,
                    previousVC.parent == nil {
                    
                    present(viewController: previousVC)
                }
                
                // Perform the "disappear" sequence of methods manually when the view of
                // the controller is not visible at all.
                
                previousViewController?.willMove(toParentViewController: self)
                previousViewController?.viewWillDisappear(false)
                previousViewController?.viewDidDisappear(false)
                previousViewController?.didMove(toParentViewController: self)
                
                // Change to current page
                currentPageIndex = targetPageIndex
                
                currentViewController?.willMove(toParentViewController: self)
                currentViewController?.viewWillAppear(false)
                currentViewController?.viewDidAppear(false)
                currentViewController?.didMove(toParentViewController: self)
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
    
    
    /// Returns a boolean defining whether the given productIndex is a valid index
    /// meaning it is not out of bounds of the current array of preloaded vcs
    /// - Parameter productIndex: The product index to evaluate
    /// - Returns: Whether the index is valid (in bounds)
    fileprivate func productIndexIsValid(_ productIndex: Int) -> Bool {
        return productIndex >= 0 && productIndex < pagesCount
    }
    
    
    /// Logs current preloaded view controllers in stack of 3 with their corresponding product ids
    /// when available
    private func logPreloadedViewControllers() {
        if let _ = datasource {
            log.debug("---- PVC PVC PVC PVC PVC PVC PVC ----")
            
            for pvc in _preloadedViewControllers {
                if let ppvc = pvc as? ProductPageViewController,
                    let ppvcProduct = ppvc.product {
                    log.debug("PVC Index: \(pvc.scrollPageIndex)   ID: \(ppvcProduct.id ?? "nil")")
                } else {
                    log.debug("PVC Index: \(pvc.scrollPageIndex)")
                }
            }
            
            log.debug("---- CVC CVC CVC CVC CVC CVC CVC ----")
            
            for vc in childViewControllers {
                if let ppvc = vc as? ProductPageViewController,
                    let ppvcProduct = ppvc.product {
                    log.debug("PVC Index: \(vc.scrollPageIndex)   ID: \(ppvcProduct.id ?? "nil")")
                } else {
                    log.debug("PVC Index: \(vc.scrollPageIndex)")
                }
            }
            
            log.debug("---- --- --- --- --- --- --- --- ----")
        }
    }
    
    
    private func append(preloadedVC: UIViewController) {
        log.verbose("Appending preloaded viewcontroller for index: \(preloadedVC.scrollPageIndex)")
        _preloadedViewControllers.append(preloadedVC)
        
        logPreloadedViewControllers()
    }
    
    
    /// Preload the view controller for the given page index and its surroundings (-1 and +1)
    /// - Parameter pageIndex: The index of the page for which vc should be preloaded
    fileprivate func preloadViewController(withIndex pageIndex: Int) {
        guard let datasource = datasource else {
            log.warning("DataSource is nil for PaginatorViewController. Won't continue without it")
            return
        }
        
        if preloading {
            log.warning("Preloading is already in process. Won't continue")
            return
        }
        
        if isViewControllerPreloaded(forIndex: pageIndex) {
            preloading = true
            
            var vcs = [UIViewController]()
            
            if directedToLeftOrDown {
                if let originVC = currentViewController {
                    vcs.append(originVC)
                }
                
                if let targetVC = getOrCreateViewController(forIndex: pageIndex) {
                    vcs.append(targetVC)
                }
                
                if let afterVC = getOrCreateViewController(forIndex: pageIndex + 1) {
                    vcs.append(afterVC)
                }
            } else {
                if let beforeVC = getOrCreateViewController(forIndex: pageIndex - 1) {
                    vcs.append(beforeVC)
                }
                
                if let targetVC = getOrCreateViewController(forIndex: pageIndex) {
                    vcs.append(targetVC)
                }
                
                if let originVC = currentViewController {
                    vcs.append(originVC)
                }
            }
            
            _preloadedViewControllers = vcs
            
            cleanViewControllers()
            
            preloading = false
        } else if let preloadingViewController = datasource.viewControllerViewController(at: pageIndex) {
            preloading = true
            
            log.warning("Trying to preload a vc that should have existed in the first place: \(pageIndex)")
            log.verbose("Preloading for page index: \(pageIndex)")
            
            preloadingViewController.scrollPageIndex = pageIndex
            
            var vcs = [UIViewController]()
            
            if directedToLeftOrDown {
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
                log.verbose("Presenting preloading view controller with page index: \(pageIndex)")
                present(viewController: preloadingViewController)
            }
            
            cleanViewControllers()
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
            log.verbose("Page vc matching index is already in memory. Returning it...")
            return matchingViewController
        }
        
        log.verbose("No page vc matching index. Creating new instance from scratch...")
        
        guard let datasource = datasource else {
            log.warning("DataSource is nil for PaginatorViewController. Won't continue without it")
            return nil
        }
        
        if let newViewController = datasource.viewControllerViewController(at: index) {
            newViewController.scrollPageIndex = index
            append(preloadedVC: newViewController)
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
                    log.verbose("Getting rid of unnecessary child view controller: \(childVC.scrollPageIndex)")
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
        super.viewDidLoad()
        
        setup()
    }
    
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    
    override public func viewDidDisappear(_ animated: Bool) {
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
        // Recognizes direction
        recognizeScrollDirection(for: scrollView)
        
        // Recognizes target index
        let targetPageIndex = Int(floor((scrollViewContentOffset - pageLength / 2) / pageLength) + 1)
        containerScrollView.bounces = bounces && targetPageIndex == pagesCount - 1
        
        // Recognizes side indexes
        let scrollingProgress = scrollViewContentOffset / pageLength
        let leftPageIndex = Int(floor(scrollingProgress))
        let rightPageIndex = Int(ceil(scrollingProgress))
        
        // Preload (and adds vc) in case it's not already available
        if preloading == false {
            if directedToLeftOrDown {
                preloadViewController(withIndex: rightPageIndex)
            } else {
                preloadViewController(withIndex: leftPageIndex)
            }
        }
        
        // Presents into actual UI hierarchy
        if pageIsFullySwipped && currentPageIndex != targetPageIndex {
            if productIndexIsValid(targetPageIndex) {
                moveTo(pageIndex: targetPageIndex)
            }
        }
    }
    
    
    private var pageIsFullySwipped: Bool {
        return Int(scrollViewContentOffset) % Int(pageLength) == 0
    }
    
    
    /// Update direction and last content offset
    /// - Parameter scrollView: scrollView for which the scroll direction should be recognized
    private func recognizeScrollDirection(for scrollView: UIScrollView) {
        scrollDirection = .none
        
        if direction == .Horizontal {
            if lastContentOffset > scrollView.contentOffset.x {
                scrollDirection = .right
            } else if lastContentOffset < scrollView.contentOffset.x {
                scrollDirection = .left
            }
            
            lastContentOffset = scrollView.contentOffset.x
        } else {
            if lastContentOffset > scrollView.contentOffset.y {
                scrollDirection = .down
            } else if lastContentOffset < scrollView.contentOffset.y {
                scrollDirection = .up
            }
            
            lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    
    private func managePagingScrollingPercentage() {
        
    }
    
}
