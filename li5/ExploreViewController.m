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

@interface ExploreViewController ()

@property (weak, nonatomic) IBOutlet Li5SearchBarUIView *searchBar;
@property (weak, nonatomic) IBOutlet UIView *suggestionsView;
@property (weak, nonatomic) IBOutlet UIView *exploreView;

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
    
    [self.searchBar setDelegate:self];
    
    [self.view bringSubviewToFront:_exploreView];
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

- (IBAction)goBack:(UIButton *)sender
{
    [_panTarget dismissViewWithCompletion:nil];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(Li5SearchBarUIView *)searchBar textDidChange:(NSString *)searchText
{
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchBar:textDidChange:)])
        {
            [controller searchBar:searchBar textDidChange:searchText];
        }
    }
}

- (BOOL)shouldBeginEditing:(Li5SearchBarUIView *)searchBar
{
    [self.view bringSubviewToFront:_suggestionsView];
    
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
    [self.view endEditing:YES];
    [self.view bringSubviewToFront:_exploreView];
    
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController, _suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(searchButtonClicked:)])
        {
            return [controller searchButtonClicked:searchBar];
        }
    }
}

- (void)cancelButtonClicked:(Li5SearchBarUIView *)searchBar
{
    [self.view endEditing:true];
    [self.view bringSubviewToFront:_exploreView];
    
    for (UIViewController<Li5SearchBarUIViewDelegate> *controller in @[_productsViewController, _tagsViewController,_suggestionsViewController]) {
        if ([controller respondsToSelector:@selector(cancelButtonClicked:)])
        {
            return [controller cancelButtonClicked:searchBar];
        }
    }
}

- (void)updateSearchBardWith:(NSString *)text
{
    [_searchBar setText:text];
    [self searchButtonClicked: _searchBar];
}

- (void)appendSearchBardWith:(NSString *)text
{
    [_searchBar setText:[_searchBar.text stringByAppendingFormat:@" %@",text]];
    [self searchButtonClicked: _searchBar];
}

#pragma mark - OS Actions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
