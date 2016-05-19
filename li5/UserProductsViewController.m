//
//  UserProductsViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/18/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "UserProductsViewController.h"
#import "UserProductsCollectionViewDataSource.h"

@interface UserProductsViewController ()

@property (nonatomic, strong) UserProductsCollectionViewDataSource *source;

@end

@implementation UserProductsViewController

- (instancetype)init
{
    DDLogVerbose(@"");
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _source = [UserProductsCollectionViewDataSource new];
    
    [_lovesCollectionView registerNib:[UINib nibWithNibName:@"ProductsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"lovesCollectionCell"];
    _lovesCollectionView.dataSource = _source;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
}

#pragma mark - Data Methods

- (void)reloadData
{
    DDLogVerbose(@"");
    [_source getUserLovesWithCompletion:^(NSError *error) {
        if (!error)
        {
            [_lovesCollectionView reloadData];
        }
    }];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
