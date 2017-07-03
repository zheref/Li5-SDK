//
//  PrimeTimeViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol PrimeTimeViewControllerProtocol {
    
    
    init(withDataSource dataSource: PrimeTimeViewControllerDataSource)
    
    var startIndex: Int { get set }
    
}


class PrimeTimeViewController : PaginatorViewController, PrimeTimeViewControllerProtocol {
    
    // MARK: STORED PROPERTIES
    
    var startIndex: Int {
        didSet {
            primeTimeLoaded = true
        }
    }
    
    var primeTimeLoading = false
    var primeTimeLoaded = false
    
    // MARK: - COMPUTED PROPERTIES
    
    var primeTimeDataSource: PrimeTimeViewControllerDataSource {
        return datasource as! PrimeTimeViewControllerDataSource
    }
    
    // MARK: - INITIALIZERS
    
    
    required init(withDataSource dataSource: PrimeTimeViewControllerDataSource) {
        log.verbose("Initializing instance of PrimeTimeViewController")
        
        startIndex = 0
        
        super.init(withDirection: .Horizontal)
        
        self.datasource = dataSource
        
        operationQueue = OperationQueue()
        operationQueue.name = "PrimeTime Queue"
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log.verbose("PrimeTimeViewController did load")
        
        setupPrimeTime()
        
        load() { [weak self] in
            self?.startPrimeTime()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewWillLayoutSubviews() {
        currentViewController?.view.frame = view.bounds
    }
    
    
    override func viewDidLayoutSubviews() {
        log.verbose("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
    }
    
    
    deinit {
        log.verbose("Deallocating instance of PrimeTimeViewController")
    }
    
    // MARK: - ROUTINES
    
    
    func setupPrimeTime() {
        view.isOpaque = false
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    func load(then: @escaping () -> Void) {
        log.verbose("Checking need to load PrimeTime data...")
        
        if primeTimeLoading {
            log.warning("PrimeTime data is already LOADING. Won't order to load again!")
        } else {
            loadDataIfNeeded(then: then)
        }
    }
    
    
    private func loadDataIfNeeded(then: @escaping () -> Void) {
        
        if primeTimeLoaded {
            log.verbose("PrimeTime data is already LOADED. Starting PrimeTime...")
            then()
        } else {
            operationQueue.addOperation { [weak self] in
                if let this = self {
                    this.primeTimeLoading = true
                    
                    this.primeTimeDataSource.fetchProducts(returner: { [weak self] (products) in
                        if let this = self {
                            this.primeTimeLoading = false
                            then()
                        } else {
                            log.warning("Skipped processing of primetime data. Self got lost")
                        }
                    }, handler: { (error) in
                        log.error(error.localizedDescription)
                    })
                } else {
                    log.warning("Skipped load primetime data operation. Self got lost")
                }
            }
        }
        
    }
    
    
    func startPrimeTime() {
        log.verbose("Starting prime time...")
        
        let firstPageViewController = primeTimeDataSource.productPageViewController(atIndex: startIndex)
        firstPageViewController.scrollPageIndex = startIndex
        preloadedViewControllers = [firstPageViewController]
        
        log.verbose("Calling relayout manually...")
        relayout()
        
        firstPageViewController.beginAppearanceTransition(true, animated: false)
        firstPageViewController.endAppearanceTransition()
    }
    
    
    
    
}
