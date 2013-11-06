//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@class MWZoomingScrollView;
@protocol MWZoomingScrollDelegate <NSObject>
- (void) ScrollViewDidZoomin;
- (void) ScrollViewDidZoomout;
@end

@class MWPhotoBrowser, MWPhoto, MWCaptionView;
@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate> {
	
	MWPhotoBrowser *_photoBrowser;
    id<MWPhoto> _photo;
	
    // This view references the related caption view for simplified
    // handling in photo browser
    MWCaptionView *_captionView;
    
	MWTapDetectingView *_tapView; // for background taps
	MWTapDetectingImageView *_photoImageView;
	UIActivityIndicatorView *_spinner;
    UILabel *tintLabel;
    id <MWZoomingScrollDelegate> zoomingDelegate;
	
}

@property (nonatomic, retain) MWCaptionView *captionView;
@property (nonatomic, retain) id <MWPhoto> photo;
@property (nonatomic, retain) id <MWZoomingScrollDelegate> zoomingDelegate;

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser zommingDelegate:(id <MWZoomingScrollDelegate>) zoomDelegate;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
