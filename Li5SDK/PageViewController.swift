//
//  PageViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit


enum PaginationDirection {
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


class PageViewController : UIViewController {
    
    // MARK: - PUBLIC INTERFACE
    
    // MARK: Stored Properties
    
    var datasource: PageViewControllerDataSource?
    var delegate: PageViewControllerDelegate?
    var viewControllers = [UIViewController]()
    var currentViewController: UIViewController?
    
    
    var direction = PaginationDirection.Horizontal
    var bounces = true
    
    
    // MARK: Initializers
    
    init(withDirection direction: PaginationDirection) {
        operationQueue = OperationQueue()
        super.init(nibName: "PageViewController", bundle: Bundle(for: PageViewController.self))
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
        super.init(nibName: "PageViewController", bundle: Bundle(for: PageViewController.self))
        self.reset()
    }
    
    // MARK: - PRIVATE INTERFACE
    
    // MARK: Stored Properties
    
    // MARK: Thread related
    
    var operationQueue: OperationQueue
    var preloading = false
    
    // MARK: Behavior
    
    var scrollDirection: ScrollDirection?
    
    var currentPageIndex: Int = 0 {
        didSet {
            log.verbose("Set new current page index to: \(currentPageIndex)")
            
            guard let datasource = datasource else {
                log.warning("DataSource is nil for PageViewController")
                return
            }
            
            if currentPageIndex >= datasource.pagesCount {
                log.verbose("Restoring page index to a safe position since it is out of bounds")
                currentPageIndex = datasource.pagesCount - 1
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
    
    
    // MARK: Routines
    
    
    func reset() {
        viewControllers = [UIViewController]()
        datasource = nil
        bounces = true
        
        fullySwitchedPageIndex = 0
        currentPageIndex = 0
        
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
        guard let datasource = datasource else {
            log.warning("DataSource is nil for PageViewController")
            return
        }
        
        log.verbose("Updating scroll view content (?)...")
        
        containerScrollView.delegate = nil
        
        pageLength = direction == .Vertical ? view.bounds.size.height : view.bounds.size.width // Do we need to reupdate this???
        
        containerScrollView.contentSize = CGSize(width: direction == .Horizontal ? CGFloat(datasource.pagesCount) * view.bounds.size.width : 1.0,
                                                 height: direction == .Vertical ? CGFloat(datasource.pagesCount) * view.bounds.size.height : 1.0)
        
        containerScrollView.contentOffset = CGPoint(x: direction == .Horizontal ? CGFloat(currentPageIndex) * view.bounds.size.width : 0.0,
                                                    y: direction == .Vertical ? CGFloat(currentPageIndex) * view.bounds.size.height : 0.0)
        
        containerScrollView.delegate = self
    }
    
    
    func setFullySwitchedPage(pageIndex: Int) {
        guard let datasource = datasource else {
            log.warning("DataSource is nil for PageViewController")
            return
        }
        
        log.debug("Running setFullySwitchedPage...")
        
        if fullySwitchedPageIndex != pageIndex {
            
            if fullySwitchedPageIndex < datasource.pagesCount {
                
                let fromPageIndex = currentPageIndex
                
                // This method is super confusing
            }
            
        }
    }
    
    
    func preloadViewController(withIndex index: Int) {
        guard let datasource = datasource, preloading else {
            if preloading {
                log.warning("Preloading is already in process")
            } else {
                log.warning("DataSource is nil for PageViewController")
            }
            return
        }
        
        if isViewControllerPreloaded(forIndex: index) {
            log.verbose("Not preloading since vc for index: \(index) is already in memory")
        }
        
        preloading = true
        
        if let preloadingViewController = datasource.viewControllerViewController(at: index) {
            preloadingViewController.scrollPageIndex = index
            
            
        }
    }
    
    
    func isViewControllerPreloaded(forIndex index: Int) -> Bool {
        for vc in viewControllers {
            if vc.scrollPageIndex == index {
                return true
            }
        }
        
        return false
    }
    
    // MARK: LIFECYCLE
    
    
    override func viewDidLoad() {
        log.debug("PageViewController did load :)")
        super.viewDidLoad()
        
        setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        log.debug("PageViewController did appear")
        super.viewDidAppear(animated)
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.debug("PageViewController did disappear")
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    
}


extension PageViewController : UIScrollViewDelegate {
    
}
