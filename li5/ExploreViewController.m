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

@interface ExploreViewController ()

@property (nonatomic, weak) ProductsViewController *productsViewController;
@property (nonatomic, weak) TagsViewController *tagsViewController;
@property (nonatomic, weak) SuggestionsViewController *suggestionsViewController;

@property (nonatomic, strong) UIPanGestureRecognizer *goBackPanGestureRecognizer;

@end

@implementation ExploreViewController

#pragma mark - Init

- (void)awakeFromNib
{
    //Do nothing for now
}

#pragma mark - UI Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_searchBar setShowsCancelButton:NO];
    
    [self.view bringSubviewToFront:_exploreView];
    
    [self setupGestureRecognizers];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    for (UIViewController<UISearchBarDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBar:textDidChange:)])
        {
            [controller searchBar:searchBar textDidChange:searchText];
        }
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:TRUE];
    [self.view bringSubviewToFront:_suggestionsView];
    
    for (UIViewController<UISearchBarDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBarShouldBeginEditing:)])
        {
            return [controller searchBarShouldBeginEditing:searchBar];
        }
    }
    
    return TRUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    [_searchBar setShowsCancelButton:NO animated:TRUE];
    [self.view bringSubviewToFront:_exploreView];
    
    for (UIViewController<UISearchBarDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBarSearchButtonClicked:)])
        {
            return [controller searchBarSearchButtonClicked:searchBar];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:TRUE];
    [self.view endEditing:true];
    [self.view bringSubviewToFront:_exploreView];
    [_searchBar setText:@""];
    
    for (UIViewController<UISearchBarDelegate> *controller in @[_productsViewController, _tagsViewController,_suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        {
            return [controller searchBarCancelButtonClicked:searchBar];
        }
    }
}

- (void)updateSearchBardWith:(NSString *)text
{
    [_searchBar setText:text];
    [self searchBarSearchButtonClicked: _searchBar];
}

- (void)appendSearchBardWith:(NSString *)text
{
    [_searchBar setText:[_searchBar.text stringByAppendingFormat:@" %@",text]];
    [self searchBarSearchButtonClicked: _searchBar];
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers
{
    _goBackPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    _goBackPanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_goBackPanGestureRecognizer];
    
}

- (void)userDidPan:(UIPanGestureRecognizer *)recognizer
{
    [_panTarget userDidPan:recognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (gestureRecognizer == self.goBackPanGestureRecognizer)
    {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
        double degree = atan(velocity.y/velocity.x) * 180 / M_PI;
        return (touch.y >= 50) && (fabs(degree) > 20.0);
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]])
    {
        if (otherGestureRecognizer == self.goBackPanGestureRecognizer)
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
