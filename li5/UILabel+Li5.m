//
//  UILabel+Li5.m
//  li5
//
//  Created by Martin Cocaro on 6/6/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//
@import CoreText;

#import "UILabel+Li5.h"

@implementation UILabel (Li5)

- (NSArray *)truncatedStrings
{
    NSMutableArray *textChunks = [[NSMutableArray alloc] init];
    
    NSMutableAttributedString *attrString = [self.attributedText mutableCopy];
    CTFramesetterRef frameSetter;
    
    CFRange fitRange;
    while (attrString.length>0) {
        
        frameSetter = CTFramesetterCreateWithAttributedString ((__bridge CFAttributedStringRef) attrString);
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0,0), NULL, CGSizeMake(self.bounds.size.width, self.bounds.size.height), &fitRange);
        CFRelease(frameSetter);
        
        NSString *chunk = [[attrString attributedSubstringFromRange:NSMakeRange(0, fitRange.length)] string];
        
        [textChunks addObject:chunk];
        
        [attrString setAttributedString: [attrString attributedSubstringFromRange:NSMakeRange(fitRange.length, attrString.string.length-fitRange.length)]];
        
    }
    return textChunks;
}

@end
