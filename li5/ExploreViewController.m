//
//  SearchViewController.m
//  li5
//
//  Created by Martin Cocaro on 5/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "TagsViewController.h"
#import "ProductsViewController.h"
#import "SuggestionsViewController.h"
#import "Li5SearchBarUIView.h"
#import "Li5VolumeView.h"

@interface ExploreViewController ()

@property (weak, nonatomic) IBOutlet Li5SearchBarUIView *searchBar;
@property (weak, nonatomic) IBOutlet UIView *suggestionsView;
@property (weak, nonatomic) IBOutlet UIView *exploreView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeftConstraintC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeftConstraintR;
@property (strong, nonatomic) NSLayoutConstraint *searchBarLeftConstraint;

@property (strong, nonatomic) MASConstraint *hiddenSearchBarConstraint;
@property (strong, nonatomic) MASConstraint *hiddenBackButtonConstraint;

@property (nonatomic, weak) ProductsViewController *productsViewController;
@property (nonatomic, weak) TagsViewController *tagsViewController;
@property (nonatomic, weak) SuggestionsViewController *suggestionsViewController;

@end

@implementation ExploreViewController

#pragma mark - Init

- (void)awakeFromNib
{
    DDLogVerbose(@"");
    //Do nothing for now
    [super awakeFromNib];
}

#pragma mark - UI Setup

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    DDLogVerbose(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.searchBar setDelegate:self];
    
    [self.view bringSubviewToFront:_exploreView];
    
    [self.view addSubview:[[Li5VolumeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0)]];
    
    [_productsViewController searchButtonClicked:_searchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"");
    [super viewDidAppear:animated];
    
   // [_productsViewController searchButtonClicked:_searchBar];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogVerbose(@"");
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"showProductsEmbed"])
    {
        _productsViewController = (ProductsViewController *) [segue destinationViewController];
    }
    else if ([segueName isEqualToString: @"showTagsEmbed"])
    {
        _tagsViewController = (TagsViewController *) [segue destinationViewController];
        [_tagsViewController setDelegate:self];
    }
    else if ([segueName isEqualToString:@"showSuggestionsEmbed"])
    {
        _suggestionsViewController = (SuggestionsViewController*) [segue destinationViewController];
        [_suggestionsViewController setDelegate:self];
    }
}

- (IBAction)goBack:(UIButton *)sender
{
    DDLogVerbose(@"");
    [_panTarget dismissViewWithCompletion:nil];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(Li5SearchBarUIView *)searchBar textDidChange:(NSString *)searchText
{
    DDLogVerbose(@"");
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBar:textDidChange:)])
        {
            [controller searchBar:searchBar textDidChange:searchText];
        }
    }
}

- (BOOL)shouldBeginEditing:(Li5SearchBarUIView *)searchBar
{
    DDLogVerbose(@"");
    [self.view bringSubviewToFront:_suggestionsView];
    
    self.searchBarLeftConstraint = ([self.searchBarLeftConstraintC isActive] ? self.searchBarLeftConstraintC : self.searchBarLeftConstraintR );
    
    [NSLayoutConstraint deactivateConstraints:@[self.backButtonLeftConstraint, self.searchBarLeftConstraint]];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        self.hiddenBackButtonConstraint = make.leading.equalTo(self.backButton.superview.leading).offset(-self.backButton.bounds.size.width);
    }];
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        self.hiddenSearchBarConstraint = make.leading.equalTo(self.searchBar.superview.leading).offset(5.0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(shouldBeginEditing:)])
        {
            return [controller shouldBeginEditing:searchBar];
        }
    }
    
    return TRUE;
}

- (void)searchButtonClicked:(Li5SearchBarUIView *)searchBar
{
    DDLogVerbose(@"");
    [self.view endEditing:YES];
    [self.view bringSubviewToFront:_exploreView];
    
    if (![self.backButtonLeftConstraint isActive])
    {
        [self.hiddenSearchBarConstraint uninstall];
        [self.hiddenBackButtonConstraint uninstall];
        [NSLayoutConstraint activateConstraints:@[self.backButtonLeftConstraint,self.searchBarLeftConstraint]];
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchButtonClicked:)])
        {
            return [controller searchButtonClicked:searchBar];
        }
    }
}

- (void)cancelButtonClicked:(Li5SearchBarUIView *)searchBar
{
    DDLogVerbose(@"");
    [self.view endEditing:true];
    [self.view bringSubviewToFront:_exploreView];
    
    if (![self.backButtonLeftConstraint isActive])
    {
        [self.hiddenSearchBarConstraint uninstall];
        [self.hiddenBackButtonConstraint uninstall];
        [NSLayoutConstraint activateConstraints:@[self.backButtonLeftConstraint,self.searchBarLeftConstraint]];
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController,_suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(cancelButtonClicked:)])
        {
            return [controller cancelButtonClicked:searchBar];
        }
    }
}

- (void)updateSearchBardWith:(NSString *)text
{
    DDLogVerbose(@"");
    [_searchBar setText:text];
    [self searchButtonClicked: _searchBar];
}

- (void)appendSearchBardWith:(NSString *)text
{
    DDLogVerbose(@"");
    NSString *textToAdd = ([_searchBar.text length] > 0 ? [_searchBar.text stringByAppendingFormat:@" %@", text] :  text);
    [_searchBar setText:textToAdd];
    [self searchButtonClicked: _searchBar];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    DDLogVerbose(@"");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
