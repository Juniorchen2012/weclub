//
//  ZDPageControll.m
//  WeClub
//
//  Created by mitbbs on 13-9-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ZDPageControll.h"

@implementation ZDPageControll
@synthesize kSpacing=_kSpacing;
- (id)initWithFrame:(CGRect)frame currentImageName:(NSString *)current commonImageName:(NSString *)common
{
    self= [super initWithFrame:frame];
    if ([self respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)] && [self respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
        [self setCurrentPageIndicatorTintColor:[UIColor clearColor]];
        [self setPageIndicatorTintColor:[UIColor clearColor]];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    _activeImage= [UIImage imageNamed:current];
    _inactiveImage= [UIImage imageNamed:common];
    _kSpacing=10.0f;
    //hold住原来pagecontroll的subview
    _usedToRetainOriginalSubview=[NSArray arrayWithArray:self.subviews];
    for (UIView *su in self.subviews) {
        [su removeFromSuperview];
    }
    self.contentMode=UIViewContentModeRedraw;
    return self;
}
-(void)dealloc
{
    //释放原来hold住的那些subview
    _usedToRetainOriginalSubview=nil;
    _activeImage=nil;
    _inactiveImage=nil;
}
- (void)updateDots
{
    
    for (int i = 0; i< [self.subviews count]; i++) {
        UIImageView* dot =[self.subviews objectAtIndex:i];
        
        if (i == self.currentPage) {
            if ([dot respondsToSelector:@selector(setImage:)]) {
                dot.image=_activeImage;
            }
            
        } else {
            if ([dot respondsToSelector:@selector(setImage:)]) {
                dot.image=_inactiveImage;
            }
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] <=6.0) {
        [self updateDots];
    }
    //    [self updateDots];
    [self setNeedsDisplay];
}
- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    [super setNumberOfPages:numberOfPages];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] <=6.0) {
        [self updateDots];
    }
    //    [self updateDots];
    [self setNeedsDisplay];
    
}
-(void)drawRect:(CGRect)iRect
{
    if (iosVersion>=7.0){//加个判断
        int i;
        CGRect rect;
        
        UIImage *image;
        iRect = self.bounds;
        
        if ( self.opaque ) {
            [self.backgroundColor set];
            UIRectFill( iRect );
        }
        
        if ( self.hidesForSinglePage && self.numberOfPages == 1 ) return;
        
        rect.size.height = _activeImage.size.height;
        rect.size.width = self.numberOfPages * _activeImage.size.width + ( self.numberOfPages - 1 ) * _kSpacing;
        rect.origin.x = floorf( ( iRect.size.width - rect.size.width ) / 2.0 );
        rect.origin.y = floorf( ( iRect.size.height - rect.size.height ) / 2.0 );
        rect.size.width = _activeImage.size.width;
        
        for ( i = 0; i < self.numberOfPages; ++i ) {
            image = i == self.currentPage ? _activeImage : _inactiveImage;
            
            [image drawInRect: rect];
            
            rect.origin.x += _activeImage.size.width + _kSpacing;
        }
    }else {
        
    }
    
}
@end
