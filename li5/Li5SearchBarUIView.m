//
//  Li5SearchBarUIView.m
//  li5
//
//  Created by Martin Cocaro on 6/9/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import "Li5SearchBarUIView.h"
#import "Li5SearchBarUICollectionViewCell.h"

@interface Li5SearchBarUIView ()

@property (assign, nonatomic) BOOL isTyping;

@property (strong, nonatomic) NSMutableArray *terms;

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *typingView;
@property (weak, nonatomic) IBOutlet UIView *typedView;

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UICollectionView *searchTermsCollectionView;

@end

@implementation Li5SearchBarUIView

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [super initialize];
    
    _terms = [NSMutableArray array];
    _isTyping = NO;
    [_searchTermsCollectionView registerNib:[UINib nibWithNibName:@"Li5SearchBarUICollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"searchTermView"];
    
}

- (void)layoutSubviews
{
    BOOL hasSearchTerms = [self.terms count] > 0;
    self.typedView.hidden = !hasSearchTerms || self.isTyping;
    self.emptyView.hidden = hasSearchTerms || self.isTyping;
    self.typingView.hidden = !self.isTyping;
    
    if (!self.typedView.hidden)
    {
        [self bringSubviewToFront:self.typedView];
    }
    else if (!self.emptyView.hidden)
    {
        [self bringSubviewToFront:self.emptyView];
    }
    else if (!self.typingView.hidden)
    {
        [self.inputField becomeFirstResponder];
        self.inputField.text = [self.terms componentsJoinedByString:@" "];
        [self bringSubviewToFront:self.typingView];
    }
    
    [super layoutSubviews];
}

#pragma mark - Private Methods

- (void)removeLastSearchTerm
{
    if ([self.terms count] > 0)
    {
        [self.terms removeAllObjects];
        [self.searchTermsCollectionView reloadData];
        
        if (self.delegate)
        {
            [self.delegate searchBar:self textDidChange:self.text];
        }
        
        [self setNeedsLayout];
    }
}

#pragma mark - Public Methods

- (void)setText:(NSString *)text
{
    [self.terms removeAllObjects];
    [self.terms addObjectsFromArray:[text componentsSeparatedByString:@" "]];
    [self.searchTermsCollectionView reloadData];
    
    self.isTyping = FALSE;
    
    if (self.delegate)
    {
        [self.delegate searchBar:self textDidChange:self.text];
    }
    
    [self setNeedsLayout];
}

- (NSString *)text
{
    return [self.terms componentsJoinedByString:@" "];
}

#pragma mark - Gesture Recognizers

- (IBAction)userDidTapSearchBarView:(UITapGestureRecognizer*)sender
{
    self.isTyping = TRUE;
    
    [self setNeedsLayout];
    
    if (self.delegate)
    {
        [self.delegate shouldBeginEditing:self];
    }
}

- (IBAction)userDidTapCancelButton:(UIButton*)sender
{
    [self.inputField resignFirstResponder];
    self.isTyping = FALSE;
    
    [self setNeedsLayout];
    
    if (self.delegate)
    {
        [self.delegate cancelButtonClicked:self];
    }
}

- (IBAction)userDidTapRemoveLast:(UIButton*)sender
{
    [self removeLastSearchTerm];
    
    if (self.delegate)
    {
        [self.delegate cancelButtonClicked:self];
    }
}

#pragma mark - UITextFieldDelegate

- (IBAction)textDidChange:(id)sender {
    if (self.delegate)
    {
        [self.delegate searchBar:self textDidChange:self.inputField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.inputField resignFirstResponder];
    
    [self setText:textField.text];
    self.isTyping = FALSE;
    
    [self setNeedsLayout];
    
    if (self.delegate)
    {
        [self.delegate searchButtonClicked:self];
    }
    
    return TRUE;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_terms count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize lblSize = [[_terms objectAtIndex:indexPath.row] sizeWithAttributes:@{
        NSFontAttributeName : [UIFont fontWithName:@"Rubik-Medium" size:15.0]
    }];

    CGSize newSize = CGSizeMake(ceil(lblSize.width*1.45+0.5),ceil(lblSize.height*1.38));
    return newSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Li5SearchBarUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchTermView" forIndexPath:indexPath];
    
    cell.termLabel.text = [_terms objectAtIndex:indexPath.row];
    
    return cell;
}

@end
