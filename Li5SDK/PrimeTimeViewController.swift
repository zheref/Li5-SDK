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
        load()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.verbose("PrimeTimeViewController did appear")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewWillLayoutSubviews() {
        currentViewController?.view.frame = view.bounds
    }
    
    
    deinit {
        log.debug("Deallocating instance of PrimeTimeViewController")
    }
    
    // MARK: - ROUTINES
    
    
    func setupPrimeTime() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    func load() {
        log.verbose("Checking need to load PrimeTime data...")
        
        if primeTimeLoading == false {
            
            if primeTimeLoaded == false {
                
                operationQueue.addOperation { [weak self] in
                    if let this = self {
                        log.verbose("Loading PrimeTime data...")
                        this.primeTimeLoading = true
                        
                        this.primeTimeDataSource.fetchProducts(withReturner: { [weak self] (products) in
                            if let this = self {
                                this.primeTimeLoading = false
                                this.startPrimeTime()
                            } else {
                                log.warning("Skipped processing of primetime data. Self got lost")
                            }
                        }, andHandler: { (error) in
                            log.error(error.localizedDescription)
                        })
                    } else {
                        log.warning("Skipped load primetime data operation. Self got lost")
                    }
                }
                
            } else {
                log.verbose("PrimeTime data is already LOADED. Starting PrimeTime...")
                startPrimeTime()
            }
            
        } else {
            log.warning("PrimeTime data is already LOADING. Won't order to load again!")
        }
    }
    
    
    func startPrimeTime() {
        log.verbose("Starting prime time...")
        
        let firstPageViewController = primeTimeDataSource.productPageViewController(atIndex: startIndex,
                                                                                    withPriority: BCPriority.buffer)
        firstPageViewController.scrollPageIndex = startIndex
        firstPageViewController.preloadedViewControllers = [firstPageViewController]
        
        relayout()
        
        firstPageViewController.beginAppearanceTransition(true, animated: false)
        firstPageViewController.endAppearanceTransition()
    }
    
    
    
    
}
